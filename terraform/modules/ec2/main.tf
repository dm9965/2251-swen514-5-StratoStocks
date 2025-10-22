resource "aws_instance" "stratostocks_ec2" {
  ami                    = var.ami  # Use the AMI we filtered above
  instance_type          = var.instance_type # Free tier eligible instance type
  subnet_id              = var.subnet_id  # Place in the public subnet just pick the first one
  vpc_security_group_ids = var.sg_ids  # Attach the EC2 security group
  key_name               = var.key_name # Replace with your SSH key pair name

  tags = {
    Name = "StratoStocks EC2 Instance"
  }
}