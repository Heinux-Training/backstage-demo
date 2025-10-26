# ArgoCD Applications with Separate Chart and Values Folders

This directory contains examples of ArgoCD applications that demonstrate different ways to manage Helm charts and values in separate folders.

## 📁 Directory Structure

```
├── application-files/          # Helm chart definitions
│   └── nginx/                 # Nginx Helm chart
│       ├── Chart.yaml
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   └── _helpers.tpl
├── application-values/        # Values files for different environments
│   ├── nginx-dev.yaml
│   ├── nginx-prod.yaml
│   └── redis-dev.yaml
└── applications/              # ArgoCD Application definitions
    ├── nginx-dev.yaml
    ├── nginx-prod.yaml
    ├── nginx-applicationset.yaml
    ├── nginx-kustomize.yaml
    └── nginx-multi-source.yaml
```

## 🚀 Application Examples

### 1. Basic Application (`nginx-dev.yaml`)
- **Use Case**: Simple deployment with values from separate folder
- **Features**: 
  - Chart from `application-files/nginx`
  - Values from `application-values/nginx-dev.yaml`
  - Basic sync policy

### 2. Production Application (`nginx-prod.yaml`)
- **Use Case**: Production deployment with different configuration
- **Features**:
  - Same chart, different values
  - Production namespace
  - LoadBalancer service type
  - Higher replica count

### 3. ApplicationSet (`nginx-applicationset.yaml`)
- **Use Case**: Deploy to multiple environments with different configurations
- **Features**:
  - Single definition for multiple environments
  - Environment-specific values files
  - Different namespaces per environment
  - Scalable approach for multiple environments

### 4. Kustomize with Helm (`nginx-kustomize.yaml`)
- **Use Case**: Advanced customization with Kustomize
- **Features**:
  - Kustomize transformations
  - Common labels and annotations
  - Name prefix/suffix
  - Image replacements

### 5. Multi-Source Application (`nginx-multi-source.yaml`)
- **Use Case**: Separate repositories for charts and values
- **Features**:
  - Multiple source references
  - Independent versioning of charts and values
  - Flexible source management

## 🔧 Configuration Options

### Values File References
```yaml
helm:
  valueFiles:
    - $values/nginx-dev.yaml  # References application-values/nginx-dev.yaml
```

### Parameters Override
```yaml
helm:
  parameters:
    - name: replicaCount
      value: "3"
    - name: service.type
      value: "LoadBalancer"
```

### Environment-Specific Configuration
```yaml
# Development
replicaCount: 1
service:
  type: ClusterIP

# Production  
replicaCount: 3
service:
  type: LoadBalancer
```

## 📋 Usage Instructions

### 1. Update Repository URLs
Replace `https://github.com/your-username/DevOps-Advanced-Course` with your actual repository URL in all application files.

### 2. Deploy Applications
```bash
# Deploy individual applications
kubectl apply -f applications/nginx-dev.yaml
kubectl apply -f applications/nginx-prod.yaml

# Deploy ApplicationSet (creates multiple applications)
kubectl apply -f applications/nginx-applicationset.yaml
```

### 3. Monitor Deployments
```bash
# Check application status
kubectl get applications -n argocd

# Check application details
kubectl describe application nginx-dev -n argocd

# Check sync status
argocd app get nginx-dev
```

## 🎯 Best Practices

### 1. Folder Organization
- **Charts**: Keep Helm charts in `application-files/`
- **Values**: Keep environment-specific values in `application-values/`
- **Applications**: Keep ArgoCD applications in `applications/`

### 2. Naming Conventions
- Use descriptive names: `nginx-dev`, `nginx-prod`
- Include environment in labels
- Use consistent naming across environments

### 3. Security
- Use separate namespaces for different environments
- Implement proper RBAC
- Use secrets management for sensitive values

### 4. Monitoring
- Enable sync policies for automated deployments
- Set up proper retry policies
- Monitor application health

## 🔍 Troubleshooting

### Common Issues

1. **Values File Not Found**
   - Check the `valueFiles` path
   - Ensure the values file exists in the repository

2. **Chart Not Found**
   - Verify the chart path in the application
   - Check if the Chart.yaml exists

3. **Sync Issues**
   - Check ArgoCD logs
   - Verify repository access
   - Ensure proper RBAC permissions

### Debug Commands
```bash
# Check application status
kubectl get applications -n argocd

# View application logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server

# Check sync status
argocd app sync nginx-dev --dry-run
```
