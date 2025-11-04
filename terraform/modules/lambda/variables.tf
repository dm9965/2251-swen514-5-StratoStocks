variable "function_name" {
  type        = string
  description = "Lambda name"
}

variable "handler" {
  type        = string
  description = "Entry point, like main.handler"
  default     = "main.handler"
}

variable "runtime" {
  type        = string
  description = "Runtime (e.g. python3.10)"
  default     = "python3.10"
}

variable "role_name" {
  type        = string
  description = "IAM role name used by the function"
  default     = "stratostocks_lambda_exec_role"
}

variable "environment_vars" {
  type        = map(string)
  description = "Env vars (optional)"
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "allow_public_invoke" {
  type    = bool
  default = false
}
