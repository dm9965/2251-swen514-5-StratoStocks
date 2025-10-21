# Create the Remote State file for team collaboration
terraform {
    backend "s3" {
        bucket = "stratostocks-terraform-state-bucket" # Bucket name
        key = "environments/prod/terraform.tfstate" # Key for the bucket
        region = "us-east-1"
        encrypt = true
        use-lockfile = true
    }
}

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

data "aws_vpc" "default" {
    default = true
}

data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}

data "aws_security_group" "default" {
    vpc_id = data.aws_vpc.default.id
    name = "default"
}

module "ec2" {
  source = "./modules/ec2"
  ami                    = data.aws_ami.amazon_linux_2023.id  # Use the AMI above
  instance_type          = "t2.micro"  # Free tier eligible instance type
  subnet_id              = tolist(data.aws_subnet_ids.default.id)[0]  # Place in the public subnet just pick the first one
  sg_ids                 = [data.aws_security_group.default.id]  # Attach the EC2 security group
  key_name               = var.key

  tags = {
    Name = "StratoStocks EC2 Instance"
  }
}