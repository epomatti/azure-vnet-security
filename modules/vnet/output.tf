output "vnet_id" {
  value = azurerm_virtual_network.vnet1.id
}

output "subnet1_id" {
  value = azurerm_subnet.subnet001.id
}

output "subnet2_id" {
  value = azurerm_subnet.subnet002.id
}

output "subnet3_id" {
  value = azurerm_subnet.subnet003.id
}

output "subnet4_id" {
  value = azurerm_subnet.subnet004.id
}

output "virtual_networks_subnet_id" {
  value = azurerm_subnet.virtual_machines.id
}

output "private_endpoints_subnet_id" {
  value = azurerm_subnet.private_endpoints.id
}

output "nsg_flowlogs_id" {
  value = azurerm_network_security_group.default.id
}
