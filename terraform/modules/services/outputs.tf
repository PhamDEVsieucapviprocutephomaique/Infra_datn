output "keyvault_id" {
  value = azurerm_key_vault.main.id
}

output "ssl_cert_secret_id" {
  value = azurerm_key_vault_secret.appgw_cert.id  # hoặc azurerm_key_vault_certificate.appgw.id
}