resource "azurerm_network_watcher" "default" {
  name                = "testnetworkwatcher"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_watcher_flow_log" "default" {
  name                 = "example-flowlog"
  network_watcher_name = azurerm_network_watcher.default.name
  resource_group_name  = var.resource_group_name
  version              = 2
  target_resource_id   = var.network_security_group_id
  storage_account_id   = var.storage_account_id
  enabled              = true

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = var.workspace_id
    workspace_region      = var.workspace_region
    workspace_resource_id = var.workspace_resource_id
    interval_in_minutes   = 10
  }
}
