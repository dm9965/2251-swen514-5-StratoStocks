variable "ami" {
    description = "Amazon Machine Image"
    type = string
}

variable "instance_type" {
    description = "Type of EC2 instance, i.e. t2.micro, etc"
    type = string
}

variable "subnet_id" {
    type = string
}

variable "sg_ids" {
    type = set(string)
}

variable "key_name" {
    type = string
}