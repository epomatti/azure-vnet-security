output "vm_id" {
  value = azurerm_linux_virtual_machine.default.id
}

output "public_ip_address" {
  value = azurerm_public_ip.default.ip_address
}

output "username" {
  value = local.username
}
