resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  location            = data.terraform_remote_state.network.outputs.location
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  sku                 = "Premium"
  admin_enabled       = false

  network_rule_set {
    default_action = "Deny"
    ip_rule        = []
    virtual_network_rule {
      action    = "Allow"
      subnet_id = data.terraform_remote_state.network.outputs.system_pool_subnet_id
    }
    virtual_network_rule {
      action    = "Allow"
      subnet_id = data.terraform_remote_state.network.outputs.app_pool_subnet_id
    }
    virtual_network_rule {
      action    = "Allow"
      subnet_id = data.terraform_remote_state.network.outputs.cron_job_pool_subnet_id
    }
  }

  georeplications {
    location                  = "eastasia"
    zone_redundancy_enabled   = true
  }

}

# AKS pull image từ ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = data.terraform_remote_state.aks.outputs.kubelet_identity_object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.main.id
}
