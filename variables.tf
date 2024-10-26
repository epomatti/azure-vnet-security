variable "subscription_id" {
  type = string
}

variable "allowed_source_address_prefixes" {
  type = list(string)
}

variable "enable_vnet_nsg_rule_virtual_machine_internet_outbound" {
  type = bool
}

variable "enable_vnet_nsg_rule_virtual_machine_virtual_network_outbound" {
  type = bool
}

variable "enable_vnet_nsg_rule_virtual_machine_asg_outbound" {
  type = bool
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2ls_v2"
}

variable "create_app_service" {
  type    = bool
  default = false
}

variable "webapp_plan_sku_name" {
  type    = string
  default = "P0v3"
}
