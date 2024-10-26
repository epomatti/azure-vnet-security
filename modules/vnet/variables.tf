variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
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

variable "asg_storage_private_endpoints_ids" {
  type = list(string)
}
