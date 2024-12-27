resource "azurerm_public_ip" "default" {
  name                = "pip-${var.workload}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "default" {
  name                = "nic-${var.workload}"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.default.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  username = "azureuser"
}

resource "azurerm_linux_virtual_machine" "default" {
  name                  = "vm-${var.workload}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.size
  admin_username        = local.username
  network_interface_ids = [azurerm_network_interface.default.id]

  custom_data = filebase64("${path.module}/custom_data/ubuntu.sh")

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = local.username
    public_key = file("${path.module}/../../keys/temp_rsa.pub")
  }

  os_disk {
    name                 = "osdisk-linux-${var.workload}"
    caching              = "ReadOnly"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  lifecycle {
    ignore_changes = [custom_data]
  }
}

resource "azurerm_virtual_machine_extension" "NetworkWatcherAgentLinux" {
  name                       = "NetworkWatcherAgentLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.default.id
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentLinux"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
}
