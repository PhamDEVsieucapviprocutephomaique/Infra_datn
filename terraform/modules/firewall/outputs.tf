output "firewall_private_ip" {
    value = azurerm_firewall.main.ip_configuration[0].private_ip_address
}
output "firewall_public_ip" {
    value = azurerm_public_ip.firewall_public_ip.ip_address
}   
output "firewall_id" {
    value = azurerm_firewall.main.id
}
output "route_table_id" {
    value = azurerm_route_table.spoke.id
}
output "bastion_public_ip" {
    value = azurerm_public_ip.bastion_public_ip.ip_address
}
output "bastion_id" {
    value = azurerm_bastion_host.main.id
}   
output "firewall_policy_id" {
    value = azurerm_firewall_policy.main.id
}
