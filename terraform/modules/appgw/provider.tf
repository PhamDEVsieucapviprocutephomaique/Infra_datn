terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.1"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "b2f492f1-5c72-428f-8abf-aed49c029ac3"
}