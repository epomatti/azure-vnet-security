terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.7.0"
    }
  }
}

locals {
  workload = "test001"
}

resource "azurerm_resource_group" "default" {
  name     = "rg-${local.workload}"
  location = var.location
}

module "vnet" {
  source              = "./modules/vnet"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  enable_vnet_nsg_rule_virtual_machine_internet_outbound        = var.enable_vnet_nsg_rule_virtual_machine_internet_outbound
  enable_vnet_nsg_rule_virtual_machine_virtual_network_outbound = var.enable_vnet_nsg_rule_virtual_machine_virtual_network_outbound
  enable_vnet_nsg_rule_virtual_machine_asg_outbound             = var.enable_vnet_nsg_rule_virtual_machine_asg_outbound

  asg_storage_private_endpoints_ids = [module.asg.asg_storage_id]
}

module "vm" {
  source              = "./modules/vm"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  subnet_id           = module.vnet.virtual_networks_subnet_id
  size                = var.vm_size
}

module "webapp" {
  count               = var.create_app_service ? 1 : 0
  source              = "./modules/webapp"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  sku_name            = var.webapp_plan_sku_name
}

### Flow Logs ###
module "storage" {
  source                          = "./modules/storage"
  resource_group_name             = azurerm_resource_group.default.name
  location                        = azurerm_resource_group.default.location
  allowed_source_address_prefixes = var.allowed_source_address_prefixes
}

module "asg" {
  source              = "./modules/asg"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
}

module "private_link" {
  source                                = "./modules/private-link"
  resource_group_name                   = azurerm_resource_group.default.name
  location                              = azurerm_resource_group.default.location
  private_endpoints_subnet_id           = module.vnet.private_endpoints_subnet_id
  vnet_id                               = module.vnet.vnet_id
  storage_account_id                    = module.storage.storage_account_id
  storage_application_security_group_id = module.asg.asg_storage_id
}

resource "azurerm_log_analytics_workspace" "default" {
  name                = "log-${local.workload}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "flowlog" {
  source              = "./modules/flowlog"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  storage_account_id        = module.storage.storage_account_id
  workspace_resource_id     = azurerm_log_analytics_workspace.default.id
  workspace_region          = azurerm_log_analytics_workspace.default.location
  workspace_id              = azurerm_log_analytics_workspace.default.workspace_id
  network_security_group_id = module.vnet.nsg_flowlogs_id
}
