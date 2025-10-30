# Sample Application Module for HPC Cluster

# Create S3 bucket for application files
resource "aws_s3_bucket" "app_bucket" {
  bucket_prefix = "${var.project_name}-apps-"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "app_bucket" {
  bucket = aws_s3_bucket.app_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "app_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.app_bucket]
  bucket     = aws_s3_bucket.app_bucket.id
  acl        = "private"
}

resource "aws_s3_bucket_versioning" "app_bucket" {
  bucket = aws_s3_bucket.app_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Upload MPI Hello World sample
resource "aws_s3_object" "mpi_hello_world_source" {
  bucket = aws_s3_bucket.app_bucket.id
  key    = "applications/mpi_hello_world/mpi_hello_world.c"
  source = "${path.module}/applications/mpi_hello_world/mpi_hello_world.c"
  etag   = filemd5("${path.module}/applications/mpi_hello_world/mpi_hello_world.c")
}

resource "aws_s3_object" "mpi_hello_world_makefile" {
  bucket = aws_s3_bucket.app_bucket.id
  key    = "applications/mpi_hello_world/Makefile"
  source = "${path.module}/applications/mpi_hello_world/Makefile"
  etag   = filemd5("${path.module}/applications/mpi_hello_world/Makefile")
}

# Upload OpenMP example
resource "aws_s3_object" "openmp_example_source" {
  bucket = aws_s3_bucket.app_bucket.id
  key    = "applications/openmp_example/openmp_example.c"
  source = "${path.module}/applications/openmp_example/openmp_example.c"
  etag   = filemd5("${path.module}/applications/openmp_example/openmp_example.c")
}

resource "aws_s3_object" "openmp_example_makefile" {
  bucket = aws_s3_bucket.app_bucket.id
  key    = "applications/openmp_example/Makefile"
  source = "${path.module}/applications/openmp_example/Makefile"
  etag   = filemd5("${path.module}/applications/openmp_example/Makefile")
}

# Upload job submission scripts
resource "aws_s3_object" "submit_mpi" {
  bucket = aws_s3_bucket.app_bucket.id
  key    = "job_scripts/submit_mpi.sh"
  source = "${path.module}/job_scripts/submit_mpi.sh"
  etag   = filemd5("${path.module}/job_scripts/submit_mpi.sh")
}

resource "aws_s3_object" "submit_openmp" {
  bucket = aws_s3_bucket.app_bucket.id
  key    = "job_scripts/submit_openmp.sh"
  source = "${path.module}/job_scripts/submit_openmp.sh"
  etag   = filemd5("${path.module}/job_scripts/submit_openmp.sh")
}

resource "aws_s3_object" "submit_hybrid" {
  bucket = aws_s3_bucket.app_bucket.id
  key    = "job_scripts/submit_hybrid.sh"
  source = "${path.module}/job_scripts/submit_hybrid.sh"
  etag   = filemd5("${path.module}/job_scripts/submit_hybrid.sh")
}

# Upload setup scripts
resource "aws_s3_object" "setup_applications" {
  bucket = aws_s3_bucket.app_bucket.id
  key    = "setup/setup_applications.sh"
  source = "${path.module}/setup/setup_applications.sh"
  etag   = filemd5("${path.module}/setup/setup_applications.sh")
}

# Generate a README with instructions
data "template_file" "readme" {
  template = file("${path.module}/templates/README.md.tpl")

  vars = {
    cluster_name         = var.cluster_name
    head_node_ip         = var.head_node_ip
    shared_storage_mount = var.shared_storage_mount
    app_bucket           = aws_s3_bucket.app_bucket.id
  }
}

resource "aws_s3_object" "readme" {
  bucket  = aws_s3_bucket.app_bucket.id
  key     = "README.md"
  content = data.template_file.readme.rendered
  etag    = md5(data.template_file.readme.rendered)
}