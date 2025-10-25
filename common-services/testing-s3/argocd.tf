# S3 bucket for ArgoCD application data
resource "aws_s3_bucket" "argocd_bucket" {
  bucket = var.bucket_name

  tags = var.tags
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "argocd_bucket_versioning" {
  bucket = aws_s3_bucket.argocd_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

# S3 bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "argocd_bucket_encryption" {
  bucket = aws_s3_bucket.argocd_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "argocd_bucket_pab" {
  bucket = aws_s3_bucket.argocd_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
