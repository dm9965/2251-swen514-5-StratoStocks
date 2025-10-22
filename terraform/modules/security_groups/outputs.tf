output "ec2_sg_id" {
  description = "EC2 security group id"
  value = aws_security_group.ec2_sg.id
}

output "rds_sg_id" {
  description = "RDS security group id"
  value = aws_security_group.rds_sg.id
}