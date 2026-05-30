output "resource_group_name" {
    value = azurerm_resource_group.main.name
}
output "location" {
    value = azurerm_resource_group.main.location
}
output "hub_vnet_name" {
    value = azurerm_virtual_network.hub.name
}
output "spoke_vnet_name" {
    value = azurerm_virtual_network.spoke.name
}
output "spoke_vnet_id" {
    value = azurerm_virtual_network.spoke.id
}
output "spoke_vnet_address_space" {
    value = azurerm_virtual_network.spoke.address_space
}

output "hub_spoke" {
    value = azurerm_virtual_network_peering.hub_spoke.name
}
output "spoke_hub" {
    value = azurerm_virtual_network_peering.spoke_hub.name
}
output "firewall_subnet_id" {
    value = azurerm_subnet.firewall_subnet.id
}
output "appgw_subnet_id" {
    value = azurerm_subnet.appgw.id
}
output "bastion_subnet_id" {
    value = azurerm_subnet.bastion_subnet.id
}
output "system_pool_subnet_id" {
    value = azurerm_subnet.system_pool_subnet.id
}
output "app_pool_subnet_id" {
    value = azurerm_subnet.app_pool_subnet.id
}
output "cron_job_pool_subnet_id" {        
    value = azurerm_subnet.cron_job_pool_subnet.id
}
output "kafka_subnet_id" {
    value = azurerm_subnet.kafka_subnet.id
}
output "database_subnet_id" {
    value = azurerm_subnet.database.id
}