resource "azurerm_public_ip" "default" {
  name                 = "pip-lb-${var.workload}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  allocation_method    = "Static"
  sku                  = "Standard"
  sku_tier             = "Regional"
  ip_version           = "IPv4"
  ddos_protection_mode = "Disabled"
}

resource "azurerm_lb" "default" {
  name                = "lb-${var.workload}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  sku_tier            = "Regional"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.default.id
  }
}
