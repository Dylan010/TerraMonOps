output "instance_ips" {
  value = aws_instance.monitoring_instance[*].public_ip
}

output "instance_ids" {
  value = aws_instance.monitoring_instance[*].id
}

output "private_key_path" {
  value = local_file.monitoring_private_key.filename
}

