variable "subscription_id" {
  type = string
}

variable "allowed_source_address_prefixes" {
  type = list(string)
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
