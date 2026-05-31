resource "azurerm_network_interface" "kafka" {
  count               = 3
  name                = "nic-kafka-${count.index}"
  location            = data.terraform_remote_state.network.outputs.location
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name

  ip_configuration {
    name                          = "ipconfig-kafka-${count.index}"
    subnet_id                     = data.terraform_remote_state.network.outputs.kafka_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.4.${count.index + 4}"
  }

}

resource "azurerm_linux_virtual_machine" "kafka" {
  count               = 3
  name                = "vm-kafka-${count.index}"
  location            = data.terraform_remote_state.network.outputs.location
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  size                = "Standard_D8s_v5"
  admin_username      = var.kafka_vm_admin_username
  zone                = tostring(count.index + 1)

  network_interface_ids = [
    azurerm_network_interface.kafka[count.index].id
  ]

  admin_ssh_key {
    username   = var.kafka_vm_admin_username
    public_key = var.kafka_vm_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }


}

# Data disk riêng cho Kafka data
resource "azurerm_managed_disk" "kafka_data" {
  count                = 3
  name                 = "disk-kafka-data-${count.index}"
  location             = data.terraform_remote_state.network.outputs.location
  resource_group_name  = data.terraform_remote_state.network.outputs.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 512
  zone                 = tostring(count.index + 1)

}

resource "azurerm_virtual_machine_data_disk_attachment" "kafka_data" {
  count              = 3
  managed_disk_id    = azurerm_managed_disk.kafka_data[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.kafka[count.index].id
  lun                = 0
  caching            = "ReadWrite"
}