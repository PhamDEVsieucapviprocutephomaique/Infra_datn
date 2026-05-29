data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "terraform-state"
    storage_account_name = "storage_account"
    container_name       = "storage_container"
    key                  = "network.tfstate"
  }
}
resource "azurerm_network_security_group" "system_pool" {
  name                = var.system_pool_nsg_name
  location            = data.terraform_remote_state.network.outputs.location
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name

  security_rule {
    name                       = "allow_https_inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "system_pool" {
  subnet_id                 = data.terraform_remote_state.network.outputs.system_pool_subnet_name
  network_security_group_id = azurerm_network_security_group.system_pool.id
}

resource "azurerm_network_security_group" "app_pool" {
  name                = var.app_pool_nsg_name
  location            = data.terraform_remote_state.network.outputs.location
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name

  security_rule {
    name                       = "allow_https_inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "app_pool" {
  subnet_id                 = data.terraform_remote_state.network.outputs.app_pool_subnet_name
  network_security_group_id = azurerm_network_security_group.app_pool.id
}


resource "azurerm_network_security_group" "cron_job_pool" {
  name                = var.cron_job_pool_nsg_name
  location            = data.terraform_remote_state.network.outputs.location
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name

  security_rule {
    name                       = "allow-internal-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = data.terraform_remote_state.network.outputs.spoke_vnet_address_space[0]
    destination_address_prefix = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "cron_job_pool" {
  subnet_id                 = data.terraform_remote_state.network.outputs.cron_job_pool_subnet_name
  network_security_group_id = azurerm_network_security_group.cron_job_pool.id
}


resource "azurerm_network_security_group" "kafka" {
  name                = var.kafka_nsg_name
  location            =data.terraform_remote_state.network.outputs.location
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name

  security_rule {
    name                       = "allow-kafka-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9092"
    source_address_prefix      = data.terraform_remote_state.network.outputs.spoke_vnet_address_space[0]
    destination_address_prefix = "*"
  }

}
resource "azurerm_subnet_network_security_group_association" "kafka" {
  subnet_id                 = data.terraform_remote_state.network.outputs.kafka_subnet_name
  network_security_group_id = azurerm_network_security_group.kafka.id
}


resource "azurerm_network_security_group" "database" {
  name                = var.database_nsg_name
  location            = data.terraform_remote_state.network.outputs.location
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name

  security_rule {
    name                       = "allow-postgres-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = data.terraform_remote_state.network.outputs.spoke_vnet_address_space[0]
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet_network_security_group_association" "database" {
  subnet_id                 = data.terraform_remote_state.network.outputs.database_subnet_name
  network_security_group_id = azurerm_network_security_group.database.id
}