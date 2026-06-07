terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}
provider "azurerm" {
  features {}
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



provider "helm" {
  kubernetes = {
    host                   = data.terraform_remote_state.aks.outputs.kube_config[0].host
    client_certificate     = base64decode(data.terraform_remote_state.aks.outputs.kube_config[0].client_certificate)
    client_key             = base64decode(data.terraform_remote_state.aks.outputs.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(data.terraform_remote_state.aks.outputs.kube_config[0].cluster_ca_certificate)
  }
}