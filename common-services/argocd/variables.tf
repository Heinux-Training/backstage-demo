variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "hhw-backstage-demo"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "argocd_namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Version of the ArgoCD Helm chart"
  type        = string
  default     = "9.0.5"  # Latest stable version
}

variable "argocd_repository" {
  description = "Helm repository for ArgoCD"
  type        = string
  default     = "https://argoproj.github.io/argo-helm"
}

variable "argocd_server_service_type" {
  description = "Service type for ArgoCD server"
  type        = string
  default     = "LoadBalancer"
}

variable "argocd_server_service_annotations" {
  description = "Annotations for ArgoCD server service"
  type        = map(string)
  default = {
    "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
  }
}

variable "argocd_admin_password" {
  description = "Admin password for ArgoCD (will be generated if not provided)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "argocd_server_insecure" {
  description = "Whether to run ArgoCD server in insecure mode"
  type        = bool
  default     = false
}

variable "argocd_server_extra_args" {
  description = "Extra arguments for ArgoCD server"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "backstage-demo"
    Environment = "dev"
    Service     = "argocd"
  }
}
