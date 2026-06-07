# ─────────────────────────────────────────
# Azure Key Vault
# ─────────────────────────────────────────
data "azurerm_client_config" "current" {}

# http ... : dùng để làm thôi product phải setup theo bastion or cách khác ,... mất thời gian .
data "http" "my_ip" {
  url = "https://api.ipify.org"
}

resource "azurerm_key_vault" "main" {
  name                        = var.keyvault_name
  location                    = data.terraform_remote_state.network.outputs.location
  resource_group_name         = data.terraform_remote_state.network.outputs.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = true
  soft_delete_retention_days  = 90
  enable_rbac_authorization   = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = [data.http.my_ip.response_body]
    # virtual_network_subnet_ids = [
    #   data.terraform_remote_state.network.outputs.system_pool_subnet_id,
    #   data.terraform_remote_state.network.outputs.app_pool_subnet_id,
    #   data.terraform_remote_state.network.outputs.cron_job_pool_subnet_id,
    #   data.terraform_remote_state.network.outputs.bastion_subnet_id,
    # ]
  }

}

# AKS đọc secret từ Key Vault qua Workload Identity
resource "azurerm_role_assignment" "aks_keyvault_reader" {
  principal_id         = data.terraform_remote_state.aks.outputs.aks_identity_principal_id
  role_definition_name = "Key Vault Secrets User"
  scope                = azurerm_key_vault.main.id
}