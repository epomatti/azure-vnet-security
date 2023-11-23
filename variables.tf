variable "location" {
  type    = string
  default = "eastus2"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2pls_v2"
}

variable "webapp_plan_sku_name" {
  type    = string
  default = "P0v3"
}
