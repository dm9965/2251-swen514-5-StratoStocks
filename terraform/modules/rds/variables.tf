variable "db_name" {
  type = "string"
  sensitive = true
  description = "Name of the Database"
}

variable "username" {
  type = "string"
  sensitive = true
  description = "Username for the Database"
}

variable "password" {
  type = "string"
  sensitive = true
  description = "Password for the Database"
}

variable "db_subnet_group_name" {
  type = "string"
  description = "Name of Subnet Group of DB"
}

variable "vpc_security_group_ids" {
  type = any
}