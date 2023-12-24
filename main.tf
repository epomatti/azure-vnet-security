terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.85.0"
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
}

module "vm" {
  source              = "./modules/vm"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  subnet_id           = module.vnet.subnet1_id
  size                = var.vm_size
}

module "webapp" {
  source              = "./modules/webapp"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  sku_name            = var.webapp_plan_sku_name
}

### Flow Logs ###
module "storage" {
  source              = "./modules/storage"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
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
