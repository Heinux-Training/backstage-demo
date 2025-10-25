# ArgoCD namespace
output "argocd_namespace" {
  description = "Kubernetes namespace where ArgoCD is deployed"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

# ArgoCD admin password
output "argocd_admin_password" {
  description = "ArgoCD admin password"
  value       = var.argocd_admin_password != "" ? var.argocd_admin_password : random_password.argocd_admin_password[0].result
  sensitive   = true
}

# ArgoCD server service information
output "argocd_server_service_name" {
  description = "Name of the ArgoCD server service"
  value       = "argocd-server"
}

output "argocd_server_service_namespace" {
  description = "Namespace of the ArgoCD server service"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

# Instructions for accessing ArgoCD
output "argocd_access_instructions" {
  description = "Instructions for accessing ArgoCD"
  value = <<-EOT
    To access ArgoCD:
    
    1. Get the LoadBalancer URL:
       kubectl get svc argocd-server -n ${kubernetes_namespace.argocd.metadata[0].name}
    
    2. Get the admin password:
       kubectl -n ${kubernetes_namespace.argocd.metadata[0].name} get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    
    3. Access ArgoCD UI:
       - If using LoadBalancer: Use the EXTERNAL-IP from the service
       - If using port-forward: kubectl port-forward svc/argocd-server -n ${kubernetes_namespace.argocd.metadata[0].name} 8080:443
    
    4. Login with:
       - Username: admin
       - Password: [from step 2]
    
    5. Install ArgoCD CLI (optional):
       curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
       sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
       rm argocd-linux-amd64
  EOT
}

# ArgoCD CLI login command
output "argocd_cli_login_command" {
  description = "Command to login to ArgoCD CLI"
  value = <<-EOT
    # Get the server URL first:
    ARGOCD_SERVER=$(kubectl get svc argocd-server -n ${kubernetes_namespace.argocd.metadata[0].name} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    
    # Login to ArgoCD CLI:
    argocd login $ARGOCD_SERVER --username admin --password $(kubectl -n ${kubernetes_namespace.argocd.metadata[0].name} get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
  EOT
}

# Helm release information
output "argocd_helm_release" {
  description = "ArgoCD Helm release information"
  value = {
    name      = helm_release.argocd.name
    namespace = helm_release.argocd.namespace
    version   = helm_release.argocd.version
    status    = helm_release.argocd.status
  }
}
