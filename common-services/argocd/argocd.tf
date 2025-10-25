# Create namespace for ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
    labels = {
      name = var.argocd_namespace
    }
  }
}

# Generate random password for ArgoCD admin if not provided
resource "random_password" "argocd_admin_password" {
  count   = var.argocd_admin_password == "" ? 1 : 0
  length  = 16
  special = true
}

# Create secret for ArgoCD admin password
resource "kubernetes_secret" "argocd_admin_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  data = {
    password = var.argocd_admin_password != "" ? var.argocd_admin_password : random_password.argocd_admin_password[0].result
  }

  type = "Opaque"
}

# Deploy ArgoCD using Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = var.argocd_repository
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  # ArgoCD server configuration
  values = [
    yamlencode({
      global = {
        domain = "argocd.${var.environment}.local" # You'll need to configure DNS
      }

      server = {
        service = {
          type        = var.argocd_server_service_type
          annotations = var.argocd_server_service_annotations
        }

        # Enable insecure mode for development (not recommended for production)
        insecure = var.argocd_server_insecure

        # Extra arguments for the server
        extraArgs = var.argocd_server_extra_args

        # Resource limits and requests
        resources = {
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
          requests = {
            cpu    = "250m"
            memory = "256Mi"
          }
        }
      }

      # ArgoCD application controller configuration
      controller = {
        resources = {
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
          requests = {
            cpu    = "250m"
            memory = "256Mi"
          }
        }
      }

      # ArgoCD repo server configuration
      repoServer = {
        resources = {
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
          requests = {
            cpu    = "250m"
            memory = "256Mi"
          }
        }
      }

      # ArgoCD dex server configuration (for SSO)
      dex = {
        enabled = false # Disable dex for now, can be enabled later for SSO
      }

      # ArgoCD notifications configuration
      notifications = {
        enabled = false # Disable notifications for now
      }

      # ArgoCD application set controller
      applicationSet = {
        enabled = true
        resources = {
          limits = {
            cpu    = "200m"
            memory = "256Mi"
          }
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

# Create a ClusterRole for ArgoCD to manage applications
resource "kubernetes_cluster_role" "argocd_application_controller" {
  metadata {
    name = "argocd-application-controller"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    non_resource_urls = ["*"]
    verbs             = ["*"]
  }
}

# Create a ClusterRoleBinding for ArgoCD application controller
resource "kubernetes_cluster_role_binding" "argocd_application_controller" {
  metadata {
    name = "argocd-application-controller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.argocd_application_controller.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "argocd-application-controller"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
}

# Create a ClusterRole for ArgoCD server
resource "kubernetes_cluster_role" "argocd_server" {
  metadata {
    name = "argocd-server"
  }

  rule {
    api_groups = [""]
    resources  = ["secrets", "configmaps"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch", "exec"]
  }
}

# Create a ClusterRoleBinding for ArgoCD server
resource "kubernetes_cluster_role_binding" "argocd_server" {
  metadata {
    name = "argocd-server"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.argocd_server.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "argocd-server"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
}

