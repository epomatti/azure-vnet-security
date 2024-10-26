output "vm_public_ip_address" {
  value = module.vm.public_ip_address
}

output "vm_ssh_connect_command" {
  value = "ssh -i keys/temp_rsa ${module.vm.username}@${module.vm.public_ip_address}"
}
