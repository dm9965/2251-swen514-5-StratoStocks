variable "vpc_id" {
  type        = string
  description = "the vpc id"
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for the route"
}

variable "gateway_id" {
  type        = string
  description = "The id  of the Internet Gateway for the route"
}

variable "route_table_name" {
  type        = string
  description = "Name tag for the route table"
}