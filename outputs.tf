output "ssh_security_group_id" {
  description = "The ID of the SSH Security Group"
  value       = aws_security_group.ssh.id
}

output "public_http_security_group_id" {
  description = "The ID of the Public HTTP Security Group"
  value       = aws_security_group.public_http.id
}

output "private_http_security_group_id" {
  description = "The ID of the Private HTTP Security Group"
  value       = aws_security_group.private_http.id
}