output "vm_public_ip_address" {
  value = module.vm.public_ip_address
}

output "vm_ssh_connect_command" {
  value = "ssh -i keys/temp_rsa ${module.vm.username}@${module.vm.public_ip_address}"
}

output "storage_primary_blob_endpoint" {
  value = module.storage.storage_primary_blob_endpoint
}

output "load_balancer_public_ip_address" {
  value = module.load_balancer.public_ip_address
}
