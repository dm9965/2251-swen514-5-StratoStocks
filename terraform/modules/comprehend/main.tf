locals {
  default_input_bucket  = "${var.project_name}-comprehend-in"
  default_output_bucket = "${var.project_name}-comprehend-out"

  in_bucket_name  = length(var.input_bucket_name)  > 0 ? var.input_bucket_name  : local.default_input_bucket
  out_bucket_name = length(var.output_bucket_name) > 0 ? var.output_bucket_name : local.default_output_bucket
}

resource "aws_kms_key" "this" {
  count               = var.enable_kms ? 1 : 0
  description         = "KMS key for ${var.project_name} Comprehend data"
  enable_key_rotation = true
  tags                = var.tags
}

resource "aws_kms_alias" "this" {
  count        = var.enable_kms ? 1 : 0
  name         = "alias/${var.project_name}-comprehend"
  target_key_id = aws_kms_key.this[0].key_id
}

resource "aws_s3_bucket" "in" {
  bucket = local.in_bucket_name
  tags   = merge(var.tags, { Purpose = "comprehend-input" })
}

resource "aws_s3_bucket_versioning" "in" {
  bucket = aws_s3_bucket.in.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_public_access_block" "in" {
  bucket                  = aws_s3_bucket.in.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "in" {
  bucket = aws_s3_bucket.in.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.enable_kms ? "aws:kms" : "AES256"
      kms_master_key_id = var.enable_kms ? aws_kms_key.this[0].arn : null
    }
  }
}


resource "aws_s3_bucket" "out" {
  bucket = local.out_bucket_name
  tags   = merge(var.tags, { Purpose = "comprehend-output" })
}

resource "aws_s3_bucket_versioning" "out" {
  bucket = aws_s3_bucket.out.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_public_access_block" "out" {
  bucket                  = aws_s3_bucket.out.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "out" {
  bucket = aws_s3_bucket.out.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.enable_kms ? "aws:kms" : "AES256"
      kms_master_key_id = var.enable_kms ? aws_kms_key.this[0].arn : null
    }
  }
}

data "aws_iam_policy_document" "assume_by_comprehend" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["comprehend.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "access" {
  name               = "${var.project_name}-comprehend-access"
  assume_role_policy = data.aws_iam_policy_document.assume_by_comprehend.json
  tags               = var.tags
}

data "aws_iam_policy_document" "access" {
  statement {
    sid     = "S3ReadInput"
    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      aws_s3_bucket.in.arn,
      "${aws_s3_bucket.in.arn}/*"
    ]
  }

  statement {
    sid     = "S3WriteOutput"
    actions = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"]
    resources = [
      aws_s3_bucket.out.arn,
      "${aws_s3_bucket.out.arn}/*"
    ]
  }

  dynamic "statement" {
    for_each = var.enable_kms ? [1] : []
    content {
      sid     = "KMSAccess"
      actions = ["kms:Encrypt","kms:Decrypt","kms:GenerateDataKey*","kms:DescribeKey"]
      resources = [aws_kms_key.this[0].arn]
    }
  }
}

resource "aws_iam_policy" "access" {
  name   = "${var.project_name}-comprehend-s3"
  policy = data.aws_iam_policy_document.access.json
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.access.name
  policy_arn = aws_iam_policy.access.arn
}
