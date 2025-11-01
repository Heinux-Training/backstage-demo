terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = "backstage-terraform-state-757641753030"
    key    = "ec2/${{ values.instanceName }}/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      ManagedBy   = "Backstage"
      Environment = "${{ values.environment }}"
      Owner       = "${{ values.owner }}"
      Project     = "${{ values.instanceName }}"
    }
  }
}

# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source for Ubuntu 22.04 AMI
data "aws_ami" "ubuntu_22_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  ami_map = {
    "amazon-linux-2023" = data.aws_ami.amazon_linux_2023.id
    "ubuntu-22.04"      = data.aws_ami.ubuntu_22_04.id
  }
  
  selected_ami = local.ami_map["${{ values.amiType }}"]
}

# Security Group
resource "aws_security_group" "instance" {
  name        = "${{ values.instanceName }}-sg"
  description = "Security group for ${{ values.instanceName }}"
  vpc_id      = var.vpc_id

  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  {% if values.enableHttp %}
  # HTTP access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  {% endif %}

  {% if values.enableHttps %}
  # HTTPS access
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  {% endif %}

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${{ values.instanceName }}-sg"
  }
}

# EC2 Instance
resource "aws_instance" "main" {
  ami           = local.selected_ami
  instance_type = "${{ values.instanceType }}"
  
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.instance.id]
  
  key_name = var.key_name
  
  {% if values.enablePublicIp %}
  associate_public_ip_address = true
  {% else %}
  associate_public_ip_address = false
  {% endif %}

  root_block_device {
    volume_size           = ${{ values.rootVolumeSize }}
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -e
              
              # Update system
              {% if values.amiType == "ubuntu-22.04" %}
              apt-get update
              apt-get upgrade -y
              
              # Install common tools
              apt-get install -y curl wget vim git htop
              {% else %}
              yum update -y
              
              # Install common tools
              yum install -y curl wget vim git htop
              {% endif %}
              
              # Create application directory
              mkdir -p /opt/app
              
              # Log completion
              echo "Instance initialization completed at $(date)" > /var/log/userdata.log
              EOF
  )

  tags = {
    Name = "${{ values.instanceName }}"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

# Elastic IP (optional)
{% if values.enableElasticIp %}
resource "aws_eip" "main" {
  instance = aws_instance.main.id
  domain   = "vpc"

  tags = {
    Name = "${{ values.instanceName }}-eip"
  }
}
{% endif %}