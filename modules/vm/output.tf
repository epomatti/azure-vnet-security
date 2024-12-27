output "vm_id" {
  value = azurerm_linux_virtual_machine.default.id
}

output "public_ip_address" {
  value = azurerm_public_ip.default.ip_address
}

output "username" {
  value = local.username
}

output "private_ip_address" {
  value = azurerm_network_interface.default.private_ip_address
}

output "network_interface_id" {
  value = azurerm_network_interface.default.id
}

output "nic_ipconfig_name" {
  value = local.nic_ipconfig_name
}
