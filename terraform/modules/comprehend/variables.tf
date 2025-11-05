variable "project_name" {
  description = "Prefix for resource names (used in bucket and role names)"
  type        = string
}

variable "enable_kms" {
  description = "If true, create a KMS key and use it for S3 default encryption"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Optional resource tags"
  type        = map(string)
  default     = {}
}

variable "input_bucket_name" {
  description = "Override for input bucket name (optional)"
  type        = string
  default     = ""
}

variable "output_bucket_name" {
  description = "Override for output bucket name (optional)"
  type        = string
  default     = ""
}
