resource "azurerm_storage_account" "default" {
  name                       = "stnsgflowlogs1238casdf"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  account_tier               = "Standard"
  account_replication_type   = "LRS"
  account_kind               = "StorageV2"
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  # Further controlled by network_rules below
  public_network_access_enabled = true

  network_rules {
    default_action             = "Deny"
    ip_rules                   = var.allowed_source_address_prefixes
    virtual_network_subnet_ids = []
    bypass                     = ["AzureServices"]
  }

  lifecycle {
    ignore_changes = [
      network_rules[0].private_link_access
    ]
  }
}
