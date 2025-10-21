variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to create the subnet in"
}

variable "cidr_block" {
  type        = string
  description = "The CIDR block for the subnet"
}

variable "az" {
  type        = string
  description = "The availability zone for the subnet"
}

variable "public" {
  type        = bool
  description = "Whether to map public IPs on launch"
  default     = false
}

variable "subnet_name" {
  type        = string
  description = "Name tag for the subnet"
}