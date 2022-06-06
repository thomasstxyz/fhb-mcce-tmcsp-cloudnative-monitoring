output "instance-manager_ip" {
  description = "IP address of manager node"
  value = aws_instance.instance-manager.public_ip
}

output "instance-worker_ip" {
  description = "IP addresses of worker nodes"
  value = aws_instance.instance-worker.*.public_ip
}
