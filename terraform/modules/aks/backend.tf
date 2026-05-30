terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state"
    storage_account_name = "storage_account"
    container_name       = "storage_container"
    key                  = "aks.tfstate"
  }
}