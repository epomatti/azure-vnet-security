### Virtual Network ###

resource "azurerm_virtual_network" "vnet1" {
  name                = "VNET1"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}


### Subnets ###

# This subnet will contain a VM.
resource "azurerm_subnet" "subnet001" {
  name                 = "Subnet-001"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.1.1.0/24"]
}

# This has Service Endpoint for storage enabled.
resource "azurerm_subnet" "subnet002" {
  name                 = "Subnet-002"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.1.2.0/24"]

  service_endpoints = ["Microsoft.Storage"]
}

# This subnet has delegation enabled, but for different service.
resource "azurerm_subnet" "subnet003" {
  name                 = "Subnet-003"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.1.3.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.ContainerInstance/containerGroups"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"
      ]
    }
  }
}

# This subnet will be empty, so any resources can be deployed to it.
resource "azurerm_subnet" "subnet004" {
  name                 = "Subnet-004"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.1.4.0/24"]
}
