output "appgw_id" {
  value = azurerm_application_gateway.main.id
}

output "appgw_public_ip" {
  value = azurerm_public_ip.appgw.ip_address
}

output "appgw_backend_pool_id" {
  value = one(azurerm_application_gateway.main.backend_address_pool).id
}

output "waf_policy_id" {
  value = azurerm_web_application_firewall_policy.main.id
}