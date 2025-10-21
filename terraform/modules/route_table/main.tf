# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block = var.cidr_block
    gateway_id = var.gateway_id
  }
  tags = {
    Name = var.route_table_name
  }
}