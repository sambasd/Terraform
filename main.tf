# Get default VPC

data "aws_vpc" "default" {
  default = true
}

# Get subnet in us-east-1a

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = ["us-east-1a"]
  }
}

# Find latest official RHEL 9 AMI

data "aws_ami" "rhel9" {
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-9*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Generate SSH private key

resource "tls_private_key" "rhel_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Register public key in AWS

resource "aws_key_pair" "rhel_key" {
  key_name   = "rhel-terraform-key"
  public_key = tls_private_key.rhel_key.public_key_openssh
}

# Save private key locally

resource "local_file" "private_key" {
  content         = tls_private_key.rhel_key.private_key_pem
  filename        = "${path.module}/rhel-terraform-key.pem"
  file_permission = "0600"
}

# Security group

resource "aws_security_group" "rhel_sg" {
  name        = "rhel-terraform-sg"
  description = "SSH access for RHEL test servers"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create two RHEL EC2 instances

resource "aws_instance" "rhel_servers" {
  count = var.instance_count

  ami           = data.aws_ami.rhel9.id
  instance_type = var.instance_type

  subnet_id = data.aws_subnets.default.ids[0]

  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.rhel_sg.id
  ]

  key_name = aws_key_pair.rhel_key.key_name

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "RHEL-SERVER-${format("%02d", count.index + 1)}"
    Environment = "Terraform-Test"
    Project     = "AWS-RHEL"
  }
}