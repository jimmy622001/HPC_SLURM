# SLURM Cluster Module using AWS ParallelCluster

# S3 bucket for ParallelCluster configuration and artifacts
resource "aws_s3_bucket" "cluster_bucket" {
  bucket_prefix = "${var.project_name}-cluster-"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "cluster_bucket" {
  bucket = aws_s3_bucket.cluster_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cluster_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.cluster_bucket]
  bucket     = aws_s3_bucket.cluster_bucket.id
  acl        = "private"
}

resource "aws_s3_bucket_versioning" "cluster_bucket" {
  bucket = aws_s3_bucket.cluster_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cluster_bucket" {
  bucket = aws_s3_bucket.cluster_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_instance" "head_node" {
  ami                    = "ami-0c55b159cbfafe1f0" # Use a valid AMI ID or data source
  instance_type          = "t3.medium"
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [var.head_node_sg_id]
  key_name               = var.ssh_key_name

  tags = {
    Name = "${var.cluster_name}-head-node"
  }
}

resource "aws_autoscaling_group" "compute_nodes" {
  name             = "${var.cluster_name}-compute-nodes"
  min_size         = 0
  max_size         = 10
  desired_capacity = 1

  vpc_zone_identifier = var.private_subnet_ids

  # You'll need to define a launch template or configuration
  launch_template {
    id      = aws_launch_template.compute_node_template.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "compute_node_template" {
  name_prefix   = "${var.cluster_name}-compute-node-"
  image_id      = "ami-0c55b159cbfafe1f0" # Use a valid AMI ID or data source
  instance_type = "t3.medium"
  key_name      = var.ssh_key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.compute_node_sg_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-compute-node"
    }
  }
}

# IAM Role for ParallelCluster
resource "aws_iam_role" "parallel_cluster_role" {
  name = "${var.project_name}-parallel-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudformation.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policies for ParallelCluster
resource "aws_iam_role_policy_attachment" "admin_policy" {
  role       = aws_iam_role.parallel_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Generate the ParallelCluster configuration file from template
data "template_file" "parallelcluster_config" {
  template = file("${path.module}/templates/parallelcluster.yaml.tpl")

  vars = {
    cluster_name            = var.cluster_name
    region                  = data.aws_region.current.id
    vpc_id                  = var.vpc_id
    subnet_ids              = join(",", var.private_subnet_ids)
    head_node_sg_id         = var.head_node_sg_id
    compute_node_sg_id      = var.compute_node_sg_id
    ssh_key_name            = var.ssh_key_name
    head_node_instance_type = var.head_node_instance_type
    compute_instance_types  = join(",", var.compute_instance_types)
    max_queue_size          = var.max_queue_size
    min_compute_nodes       = var.min_compute_nodes
    max_compute_nodes       = var.max_compute_nodes
    enable_spot_instances   = var.enable_spot_instances
    placement_group         = var.placement_group
    enable_hyperthreading   = var.enable_hyperthreading
    shared_storage_id       = var.shared_storage_id
    shared_storage_type     = var.shared_storage_type
    bucket_name             = aws_s3_bucket.cluster_bucket.id
  }
}

# Upload ParallelCluster configuration to S3
resource "aws_s3_object" "parallelcluster_config" {
  bucket  = aws_s3_bucket.cluster_bucket.id
  key     = "parallelcluster.yaml"
  content = data.template_file.parallelcluster_config.rendered
  etag    = md5(data.template_file.parallelcluster_config.rendered)
}

# Generate the cluster deployment script
data "template_file" "cluster_deploy_script" {
  template = file("${path.module}/templates/cluster_info.tpl")

  vars = {
    region        = data.aws_region.current.id
    cluster_name  = var.cluster_name
    config_s3_uri = "s3://${aws_s3_bucket.cluster_bucket.id}/parallelcluster.yaml"
  }
}

# AWS Lambda function to deploy and manage the cluster
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "cluster_manager" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "${var.project_name}-cluster-manager"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 900
  memory_size   = 256

  environment {
    variables = {
      CLUSTER_NAME  = var.cluster_name
      CONFIG_S3_URI = "s3://${aws_s3_bucket.cluster_bucket.id}/parallelcluster.yaml"
      REGION        = data.aws_region.current.id
    }
  }
}

# IAM role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.project_name}-lambda-policy"
  description = "Policy for Lambda to manage ParallelCluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.cluster_bucket.arn,
          "${aws_s3_bucket.cluster_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudformation:*",
          "ec2:*",
          "iam:PassRole",
          "lambda:*",
          "autoscaling:*",
          "cloud9:*",
          "dynamodb:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Create CloudWatch dashboard if enabled
resource "aws_cloudwatch_dashboard" "cluster_dashboard" {
  count          = var.enable_dashboard ? 1 : 0
  dashboard_name = "${var.project_name}-${var.cluster_name}-dashboard"

  dashboard_body = templatefile("${path.module}/templates/dashboard.json.tpl", {
    region       = data.aws_region.current.id
    cluster_name = var.cluster_name
  })
}

data "aws_region" "current" {}

# Null resource to trigger Lambda (in a real environment, consider using a proper trigger mechanism)
resource "null_resource" "deploy_cluster" {
  triggers = {
    config_hash = aws_s3_object.parallelcluster_config.etag
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws lambda invoke \
        --function-name ${aws_lambda_function.cluster_manager.function_name} \
        --payload '{"action": "create"}' \
        --region ${data.aws_region.current.id} \
        /tmp/lambda_output.json
    EOT
  }

  depends_on = [
    aws_lambda_function.cluster_manager,
    aws_s3_object.parallelcluster_config
  ]
}