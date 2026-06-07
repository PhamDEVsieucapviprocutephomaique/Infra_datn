
//gói free k đủ cấu hình đẻ xài.

# resource "tls_private_key" "kafka_ssh" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }


# resource "azurerm_key_vault_secret" "kafka_ssh_public" {
#   name         = "kafka-vm-ssh-public"
#   value        = tls_private_key.kafka_ssh.public_key_openssh
#   key_vault_id = azurerm_key_vault.main.id
# }

# # Lưu private key vào Key Vault
# resource "azurerm_key_vault_secret" "kafka_ssh_private" {
#   name         = "kafka-vm-ssh-private"
#   value        = tls_private_key.kafka_ssh.private_key_openssh
#   key_vault_id = azurerm_key_vault.main.id
# }



# resource "azurerm_network_interface" "kafka" {
#   count               = 1  # Chỉ 1 VM
#   name                = "nic-kafka-${count.index}"
#   location            = data.terraform_remote_state.network.outputs.location
#   resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name

#   ip_configuration {
#     name                          = "ipconfig-kafka-${count.index}"
#     subnet_id                     = data.terraform_remote_state.network.outputs.kafka_subnet_id
#     private_ip_address_allocation = "Static"
#     private_ip_address            = "10.1.4.4"  # IP cố định
#   }
# }

# resource "azurerm_linux_virtual_machine" "kafka" {
#   count               = 1  
#   name                = "vm-kafka-${count.index}"
#   location            = data.terraform_remote_state.network.outputs.location
#   resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
#   size                = "Standard_B1ls"  
#   admin_username      = var.kafka_vm_admin_username


#   network_interface_ids = [
#     azurerm_network_interface.kafka[count.index].id
#   ]

#   admin_ssh_key {
#     username   = var.kafka_vm_admin_username
#     public_key = tls_private_key.kafka_ssh.public_key_openssh
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS" 
#     disk_size_gb         = 30  
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts-gen2"
#     version   = "latest"
#   }

#   identity {
#     type = "SystemAssigned"
#   }
# }


# resource "azurerm_managed_disk" "kafka_data" {
#   count                = 1 
#   name                 = "disk-kafka-data-${count.index}"
#   location             = data.terraform_remote_state.network.outputs.location
#   resource_group_name  = data.terraform_remote_state.network.outputs.resource_group_name
#   storage_account_type = "Standard_LRS"  # HDD thường
#   create_option        = "Empty"
#   disk_size_gb         = 4  

# }

# resource "azurerm_virtual_machine_data_disk_attachment" "kafka_data" {
#   count              = 1
#   managed_disk_id    = azurerm_managed_disk.kafka_data[count.index].id
#   virtual_machine_id = azurerm_linux_virtual_machine.kafka[count.index].id
#   lun                = 0
#   caching            = "ReadWrite"
# }
