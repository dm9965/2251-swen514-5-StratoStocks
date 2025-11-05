output "comprehend_role_arn" {
  description = "IAM role ARN that Comprehend should use for data access"
  value       = aws_iam_role.access.arn
}

output "input_bucket" {
  description = "S3 bucket name for input documents"
  value       = aws_s3_bucket.in.bucket
}

output "output_bucket" {
  description = "S3 bucket name for Comprehend results"
  value       = aws_s3_bucket.out.bucket
}

output "kms_key_arn" {
  description = "KMS key ARN if created (null otherwise)"
  value       = try(aws_kms_key.this[0].arn, null)
}
