output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.main.id
}

output "instance_public_ip" {
  description = "Public IP address"
  value       = aws_instance.main.public_ip
}

output "instance_private_ip" {
  description = "Private IP address"
  value       = aws_instance.main.private_ip
}

{% if values.enableElasticIp %}
output "elastic_ip" {
  description = "Elastic IP address"
  value       = aws_eip.main.public_ip
}
{% endif %}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.instance.id
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh -i ~/.ssh/${{ values.keyName }}.pem {% if values.amiType == 'ubuntu-22.04' %}ubuntu{% else %}ec2-user{% endif %}@${aws_instance.main.public_ip}"
}