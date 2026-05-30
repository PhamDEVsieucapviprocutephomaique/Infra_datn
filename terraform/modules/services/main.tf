
data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "terraform-state"
    storage_account_name = "storage_account"
    container_name       = "storage_container"
    key                  = "network.tfstate"
  }
}


data "terraform_remote_state" "aks" {
  backend = "azurerm"
  config = {
    resource_group_name  = "terraform-state"
    storage_account_name = "storage_account"
    container_name       = "storage_container"
    key                  = "aks.tfstate"
  }
}