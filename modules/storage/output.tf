output "storage_account_id" {
  value = azurerm_storage_account.default.id
}

output "storage_primary_blob_endpoint" {
  value = azurerm_storage_account.default.primary_blob_endpoint
}
