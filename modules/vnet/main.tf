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

resource "azurerm_subnet" "virtual_machines" {
  name                 = "virutal-machines"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.1.200.0/24"]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "private-endpoints"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.1.180.0/24"]
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

### Network Security Group - Virtual Machines
resource "azurerm_network_security_group" "virtual_machines" {
  name                = "nsg-virtual-machines"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "virtual_machines_allow_inbound_ssh" {
  name                        = "AllowInboundSSH"
  priority                    = 500
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.virtual_machines.name
}

resource "azurerm_network_security_rule" "virtual_machines_allow_internet_outbound" {
  name                        = "AllowInternetOutbound"
  priority                    = 500
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = [80, 443]
  source_address_prefix       = "*"
  destination_address_prefix  = var.nsg_virtual_machines_allow_outbound_tag
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.virtual_machines.name
}

resource "azurerm_network_security_rule" "virtual_machines_deny_all_outbound" {
  name                        = "DenyAllOutbound"
  priority                    = 4096
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.virtual_machines.name
}

resource "azurerm_subnet_network_security_group_association" "virtual" {
  subnet_id                 = azurerm_subnet.virtual_machines.id
  network_security_group_id = azurerm_network_security_group.virtual_machines.id
}
