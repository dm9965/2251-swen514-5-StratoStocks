# Set the provider region
provider "aws" {
    region = "us-east-1"
}

# AMI Data Source
data "aws_ami" "amazon_linux_2023" {
  most_recent = true    # Get the latest version of the AMI
  owners      = ["amazon"]  # Only accept Amazon-owned AMIs

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]  # Filter for Amazon Linux 2023 AMIs
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]  # Hardware Virtual Machine AMIs only
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]  # EBS-backed instances only
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]  # 64-bit x86 architecture only
  }
}

module "terraform-s3-bucket" {
  source = "./modules/s3"
  bucket_name = "stratostocks-terraform-state-bucket"
}

#VPC Module
module "vpc" {
  source = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  name = "Stratostocks VPC"
}

# Public Subnet Module
module "public_subnet" {
  source        = "./modules/subnet"
  vpc_id        = module.vpc.id
  cidr_block    = "10.0.1.0/24"
  az            = "us-east-1a"
  public        = true
  subnet_name   = "Stratostocks Public Subnet"
}

# Private Subnet Module
module "private_subnet" {
  source        = "./modules/subnet"
  vpc_id        = module.vpc.id
  cidr_block    = "10.0.2.0/24"
  az            = "us-east-1b"
  public        = false
  subnet_name   = "Stratostocks private Subnet"
}

module "gateway" {
  source = "./modules/gateway"
  vpc_id = module.vpc.id
  gateway_name = "Stratostocks Internet Gateway"
}

# Public Route Table Module
module "route_table" {
  source = "./modules/route_table"
  vpc_id = module.vpc.id
  cidr_block = "0.0.0.0/0"
  gateway_id = module.gateway.id
  route_table_name = "Stratostocks Public Route Table"
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_rta" {
  subnet_id      = module.public_subnet.id
  route_table_id = module.route_table.id
}

# Security Groups
# Defines security groups to control access for EC2 and RDS instances.
module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.id
}

# Create the EC2 Instance
module "ec2" {
  source = "./modules/ec2"
  ami                    = data.aws_ami.amazon_linux_2023.id  # Use the AMI above
  instance_type          = "t2.micro"  # Free tier eligible instance type
  subnet_id              = module.public_subnet.id  # Place in the public subnet just pick the first one
  sg_ids                 = [module.security_groups.ec2_sg_id] # Attach the EC2 security group
  key_name               = var.key_name
}

# DB Subnet Group
resource "aws_db_subnet_group" "stratostocks_db_subnet_group" {
  name       = "stratostocks_db_subnet_group"
  subnet_ids = [module.private_subnet.id, module.public_subnet.id]

  tags = {
    Name = "StratoStocks DB Subnet Group"
  }
}

# Create the RDS Instance
module "rds" {
  source = "./modules/rds"
  db_name              = var.db_name  # Name of the Stratostocks database
  username             = var.db_username  # Database admin username
  password             = var.db_password  # Replace with a secure password
  vpc_security_group_ids = [module.security_groups.rds_sg_id]  # Attach the RDS security group
  db_subnet_group_name = aws_db_subnet_group.stratostocks_db_subnet_group.name  # Use the created subnet group
}

## Create the Remote State file for team collaboration
#terraform {
#  backend "s3" {
#    bucket = "stratostocks-terraform-state-bucket" # Bucket name
#    key = "environments/prod/terraform.tfstate" # Key for the bucket
#    region = "us-east-1"
#    encrypt = true
#  }
#}
