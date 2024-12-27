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

resource "azurerm_lb_backend_address_pool" "public_pool" {
  loadbalancer_id = azurerm_lb.default.id
  name            = "public-pool"
}

# https://github.com/Azure/azure-cli/issues/27090
resource "azurerm_lb_backend_address_pool" "vnet_pool" {
  loadbalancer_id    = azurerm_lb.default.id
  name               = "vnet-pool"
  virtual_network_id = var.vnet_id
  synchronous_mode   = "Automatic"
}

# This replaces "azurerm_lb_backend_address_pool_address"
# https://learn.microsoft.com/en-us/azure/load-balancer/quickstart-load-balancer-standard-internal-terraform
resource "azurerm_network_interface_backend_address_pool_association" "name" {
  network_interface_id    = var.vm001_network_interface_id
  ip_configuration_name   = "ipconfig-vm001"
  backend_address_pool_id = azurerm_lb_backend_address_pool.vnet_pool.id
}

resource "azurerm_lb_probe" "vm001_nginx" {
  loadbalancer_id = azurerm_lb.default.id
  name            = "vm001-nginx-probe"
  port            = 80
}

resource "azurerm_lb_rule" "vm001_nginx" {
  loadbalancer_id                = azurerm_lb.default.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.default.frontend_ip_configuration[0].name
  disable_outbound_snat          = true
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.vnet_pool.id]
}
