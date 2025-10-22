resource "aws_s3_bucket" "stratostocks-terraform-state-bucket" {
  bucket = var.bucket_name
  tags = {
    Name = "Stratostocks Terraform State Bucket"
  }
}

#resource "aws_s3_bucket_public_access_block" "block_public_access" {
#  bucket = aws_s3_bucket.client.id
#  block_public_acls       = false
#  ignore_public_acls      = false
#  block_public_policy     = false
#  restrict_public_buckets = false
#}
#
#resource "aws_s3_bucket_website_configuration" "website" {
#  bucket = aws_s3_bucket.client.id
#  index_document {
#    suffix = "index.html"
#  }
#  error_document {
#    key = "404.html"
#  }
#}