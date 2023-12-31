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

# This subnet has delegation enabled for SQL Managed Instance.
resource "azurerm_subnet" "subnet003" {
  name                 = "Subnet-003"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.1.3.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.Sql/managedInstances"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
}

# This subnet has delegation enabled for Microsoft.Web/serverFarms.
resource "azurerm_subnet" "subnet004" {
  name                 = "Subnet-004"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.1.4.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
    }
  }
}

# This subnet will be empty, so any resources can be deployed to it.
resource "azurerm_subnet" "subnet005" {
  name                 = "Subnet-005"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.1.5.0/24"]
}

### Flow Logs ###
resource "azurerm_subnet" "subnet_nsg_flowlogs" {
  name                 = "Subnet-NSGFlowlogs"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.1.99.0/24"]
}

resource "azurerm_network_security_group" "default" {
  name                = "nsg-flowlogs"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "default" {
  subnet_id                 = azurerm_subnet.subnet_nsg_flowlogs.id
  network_security_group_id = azurerm_network_security_group.default.id
}
