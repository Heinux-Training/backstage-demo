# EC2 Instance: ${{ values.instanceName }}

## Instance Details

- **Name:** ${{ values.instanceName }}
- **Type:** ${{ values.instanceType }}
- **AMI:** ${{ values.amiType }}
- **Environment:** ${{ values.environment }}
- **Owner:** ${{ values.owner }}

## Infrastructure

This EC2 instance is managed by Terraform and deployed via GitHub Actions.

### Configuration

- **VPC:** ${{ values.vpcId }}
- **Subnet:** ${{ values.subnetId }}
- **Key Pair:** ${{ values.keyName }}
- **Root Volume:** ${{ values.rootVolumeSize }} GB

### Network Access

{% if values.enablePublicIp %}
- ✅ Public IP enabled
{% else %}
- ❌ Private instance only
{% endif %}

{% if values.enableElasticIp %}
- ✅ Elastic IP attached
{% endif %}

**Ports:**
- SSH (22) - Open
{% if values.enableHttp %}- HTTP (80) - Open{% endif %}
{% if values.enableHttps %}- HTTPS (443) - Open{% endif %}

## Deployment

### Manual Deployment
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Automated Deployment

Push to `main` branch to trigger automatic deployment via GitHub Actions.

## Access

After deployment, get connection details:
```bash
cd terraform
terraform output ssh_command
```

Example:
```bash
ssh -i ~/.ssh/${{ values.keyName }}.pem ec2-user@<public-ip>
```

## Destroy

To destroy the instance:
```bash
cd terraform
terraform destroy
```

## Support

Owner: ${{ values.owner }}
Created: {{ now().strftime('%Y-%m-%d') }}
```

**File 7: skeleton/.gitignore**
```
# Terraform
**/.terraform/*
*.tfstate
*.tfstate.*
.terraform.lock.hcl

# Crash logs
crash.log
crash.*.log

# Sensitive files
*.tfvars.json
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# CLI config
.terraformrc
terraform.rc

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db