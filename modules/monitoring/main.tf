/*
 * Monitoring Module
 * 
 * This module sets up Prometheus and Grafana for monitoring the HPC cluster,
 * with dashboards for SLURM metrics, job statistics, and system performance.
 * 
 * Updated to support both bastion-based SSH connectivity and SSM-based connectivity.
 */

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # Use dummy certificate if specified
  use_dummy_cert = var.dummy_certificate
}

# Security Groups
resource "aws_security_group" "monitoring" {
  name        = "${local.name_prefix}-monitoring-sg"
  description = "Security group for Prometheus and Grafana"
  vpc_id      = var.vpc_id

  # HTTPS access from allowed CIDR blocks
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_monitoring_cidr_blocks
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-monitoring-sg"
    }
  )
}

# Create a self-signed certificate for HTTPS if dummy_certificate is true
resource "tls_private_key" "monitoring" {
  count     = local.use_dummy_cert ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "monitoring" {
  count           = local.use_dummy_cert ? 1 : 0
  private_key_pem = tls_private_key.monitoring[0].private_key_pem

  subject {
    common_name  = "monitoring.example.com"
    organization = "Example Monitoring"
  }

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "monitoring" {
  count            = local.use_dummy_cert ? 1 : 0
  private_key      = tls_private_key.monitoring[0].private_key_pem
  certificate_body = tls_self_signed_cert.monitoring[0].cert_pem

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-monitoring-cert"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ECS Cluster for Monitoring
resource "aws_ecs_cluster" "monitoring" {
  name = "${local.name_prefix}-monitoring"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.tags
}

# EFS for Persistent Storage
resource "aws_efs_file_system" "monitoring" {
  creation_token = "${local.name_prefix}-monitoring-efs"
  encrypted      = true

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-monitoring-efs"
    }
  )
}

resource "aws_efs_mount_target" "monitoring" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.monitoring.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.monitoring.id]
}

# ALB for Grafana access
resource "aws_lb" "monitoring" {
  name               = "${local.name_prefix}-monitoring-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.monitoring.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-monitoring-alb"
    }
  )
}

resource "aws_lb_target_group" "grafana" {
  name        = "${local.name_prefix}-grafana-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/api/health"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200"
  }

  tags = var.tags
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.monitoring.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.use_dummy_cert ? aws_acm_certificate.monitoring[0].arn : var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

# Create Prometheus task definition
resource "aws_ecs_task_definition" "prometheus" {
  family                   = "${local.name_prefix}-prometheus"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.prometheus.arn

  container_definitions = jsonencode([
    {
      name      = "prometheus"
      image     = "prom/prometheus:latest"
      essential = true
      portMappings = [
        {
          containerPort = 9090
          hostPort      = 9090
          protocol      = "tcp"
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "prometheus-data"
          containerPath = "/prometheus"
          readOnly      = false
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.monitoring.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "prometheus"
        }
      }
    }
  ])

  volume {
    name = "prometheus-data"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.monitoring.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.prometheus.id
      }
    }
  }

  tags = var.tags
}

# Create Grafana task definition
resource "aws_ecs_task_definition" "grafana" {
  family                   = "${local.name_prefix}-grafana"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.grafana.arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "grafana/grafana:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "GF_SECURITY_ADMIN_PASSWORD"
          value = var.grafana_admin_password
        },
        {
          name  = "GF_USERS_ALLOW_SIGN_UP"
          value = "false"
        },
        {
          name  = "GF_SERVER_DOMAIN"
          value = "localhost"
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "grafana-data"
          containerPath = "/var/lib/grafana"
          readOnly      = false
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.monitoring.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "grafana"
        }
      }
    }
  ])

  volume {
    name = "grafana-data"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.monitoring.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.grafana.id
      }
    }
  }

  tags = var.tags
}

# EFS Access Points
resource "aws_efs_access_point" "prometheus" {
  file_system_id = aws_efs_file_system.monitoring.id
  posix_user {
    uid = 65534 # nobody
    gid = 65534 # nobody
  }
  root_directory {
    path = "/prometheus"
    creation_info {
      owner_uid   = 65534
      owner_gid   = 65534
      permissions = "755"
    }
  }
  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-prometheus-ap"
    }
  )
}

resource "aws_efs_access_point" "grafana" {
  file_system_id = aws_efs_file_system.monitoring.id
  posix_user {
    uid = 472 # grafana
    gid = 472 # grafana
  }
  root_directory {
    path = "/grafana"
    creation_info {
      owner_uid   = 472
      owner_gid   = 472
      permissions = "755"
    }
  }
  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-grafana-ap"
    }
  )
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "monitoring" {
  name              = "/ecs/${local.name_prefix}-monitoring"
  retention_in_days = 30

  tags = var.tags
}

# IAM Roles
resource "aws_iam_role" "ecs_execution" {
  name = "${local.name_prefix}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "prometheus" {
  name = "${local.name_prefix}-prometheus-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "prometheus" {
  name = "${local.name_prefix}-prometheus-policy"
  role = aws_iam_role.prometheus.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "grafana" {
  name = "${local.name_prefix}-grafana-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# Launch Prometheus and Grafana services
resource "aws_ecs_service" "prometheus" {
  name            = "${local.name_prefix}-prometheus"
  task_definition = aws_ecs_task_definition.prometheus.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.monitoring.id]
    assign_public_ip = false
  }

  depends_on = [aws_efs_mount_target.monitoring]

  tags = var.tags
}

resource "aws_ecs_service" "grafana" {
  name            = "${local.name_prefix}-grafana"
  cluster         = aws_ecs_cluster.monitoring.id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.monitoring.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grafana.arn
    container_name   = "grafana"
    container_port   = 3000
  }

  depends_on = [aws_efs_mount_target.monitoring]

  tags = var.tags
}

# Optional Route53 DNS record
resource "aws_route53_record" "monitoring" {
  count   = var.create_route53_record ? 1 : 0
  zone_id = var.route53_zone_id
  name    = "monitoring.${var.dns_domain}"
  type    = "A"

  alias {
    name                   = aws_lb.monitoring.dns_name
    zone_id                = aws_lb.monitoring.zone_id
    evaluate_target_health = true
  }
}