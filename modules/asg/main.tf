resource "azurerm_application_security_group" "storage" {
  name                = "asg-storage"
  location            = var.location
  resource_group_name = var.resource_group_name
}
