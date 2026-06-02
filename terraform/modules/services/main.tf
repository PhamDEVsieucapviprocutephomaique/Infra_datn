
data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "terraform-state"
    storage_account_name = "9082400test"
    container_name       = "082400container"
    key                  = "network.tfstate"
  }
}


data "terraform_remote_state" "aks" {
  backend = "azurerm"
  config = {
    resource_group_name  = "terraform-state"
    storage_account_name = "9082400test"
    container_name       = "082400container"
    key                  = "aks.tfstate"
  }
}