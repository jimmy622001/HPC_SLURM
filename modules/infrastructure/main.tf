###############################################
# AWS Infrastructure Module for HPC Cluster
###############################################

# Create VPC
resource "aws_vpc" "hpc_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Create public subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.hpc_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index % length(var.availability_zones)]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
  }
}

# Create private subnets
resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.hpc_vpc.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index % length(var.availability_zones)]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.hpc_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Create public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.hpc_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Associate public route table with public subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Create NAT Gateway if enabled
resource "aws_eip" "nat_eip" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.project_name}-nat-gw"
  }
}

# Create private route table (with NAT Gateway if enabled)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.hpc_vpc.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat_gw[0].id
    }
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

# Associate private route table with private subnets
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# Create bastion host security group
resource "aws_security_group" "bastion_sg" {
  count       = var.enable_bastion_host ? 1 : 0
  name        = "${var.project_name}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.hpc_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH from Internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-bastion-sg"
  }
}

# Create bastion host
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "bastion" {
  count                       = var.enable_bastion_host ? 1 : 0
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.bastion_instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.bastion_sg[0].id]
  key_name                    = var.bastion_key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-bastion"
  }
}

# Create head node security group
resource "aws_security_group" "head_node_sg" {
  name        = "${var.project_name}-head-node-sg"
  description = "Security group for head node"
  vpc_id      = aws_vpc.hpc_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = var.enable_bastion_host ? [aws_security_group.bastion_sg[0].id] : []
    description     = "Allow SSH from bastion host"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all traffic within the security group"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-head-node-sg"
  }
}

# Create compute node security group
resource "aws_security_group" "compute_node_sg" {
  name        = "${var.project_name}-compute-node-sg"
  description = "Security group for compute nodes"
  vpc_id      = aws_vpc.hpc_vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.head_node_sg.id]
    description     = "Allow all traffic from head node"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all traffic within the security group"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-compute-node-sg"
  }
}

# Create shared storage - EFS
resource "aws_efs_file_system" "efs" {
  count            = var.enable_shared_storage && var.shared_storage_type == "efs" ? 1 : 0
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true

  tags = {
    Name = "${var.project_name}-efs"
  }
}

resource "aws_security_group" "efs_sg" {
  count       = var.enable_shared_storage && var.shared_storage_type == "efs" ? 1 : 0
  name        = "${var.project_name}-efs-sg"
  description = "Security group for EFS mount targets"
  vpc_id      = aws_vpc.hpc_vpc.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.head_node_sg.id, aws_security_group.compute_node_sg.id]
    description     = "Allow NFS traffic from cluster nodes"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-efs-sg"
  }
}

resource "aws_efs_mount_target" "efs_mount" {
  count           = var.enable_shared_storage && var.shared_storage_type == "efs" ? length(var.private_subnet_cidrs) : 0
  file_system_id  = aws_efs_file_system.efs[0].id
  subnet_id       = aws_subnet.private[count.index].id
  security_groups = [aws_security_group.efs_sg[0].id]
}

# Create shared storage - FSx for Lustre
resource "aws_security_group" "fsx_sg" {
  count       = var.enable_shared_storage && var.shared_storage_type == "fsx_lustre" ? 1 : 0
  name        = "${var.project_name}-fsx-sg"
  description = "Security group for FSx Lustre"
  vpc_id      = aws_vpc.hpc_vpc.id

  ingress {
    from_port       = 988
    to_port         = 988
    protocol        = "tcp"
    security_groups = [aws_security_group.head_node_sg.id, aws_security_group.compute_node_sg.id]
    description     = "Allow Lustre traffic from cluster nodes"
  }

  ingress {
    from_port       = 1021
    to_port         = 1023
    protocol        = "tcp"
    security_groups = [aws_security_group.head_node_sg.id, aws_security_group.compute_node_sg.id]
    description     = "Allow Lustre traffic from cluster nodes"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-fsx-sg"
  }
}

resource "aws_fsx_lustre_file_system" "fsx" {
  count              = var.enable_shared_storage && var.shared_storage_type == "fsx_lustre" ? 1 : 0
  storage_capacity   = var.fsx_lustre_capacity
  subnet_ids         = [aws_subnet.private[0].id]
  deployment_type    = var.fsx_lustre_deployment_type
  security_group_ids = [aws_security_group.fsx_sg[0].id]

  tags = {
    Name = "${var.project_name}-fsx-lustre"
  }
}
resource "aws_efs_file_system" "shared_storage" {
  creation_token = "${var.project_name}-efs"
  encrypted      = true

  tags = {
    Name = "${var.project_name}-efs"
  }
}

