resource "aws_s3_bucket" "stratostocks-terraform-state-bucket" {
  bucket = var.bucket_name
  tags = {
    Name = "Stratostocks Terraform State Bucket"
  }
}
