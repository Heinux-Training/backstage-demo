variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for ArgoCD"
  type        = string
  default     = "hhw-backstage-demo-argocd-bucket-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "DevOps-Advanced-Course"
    Environment = "dev"
    Service     = "argocd"
  }
}
