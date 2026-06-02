terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state"
    storage_account_name = "9082400test"
    container_name       = "082400container"
    key                  = "security.tfstate"
  }
}



