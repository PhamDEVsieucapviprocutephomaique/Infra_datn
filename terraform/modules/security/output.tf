output "nsg_aks_system_id" {
  value = azurerm_network_security_group.system_pool.id
}

output "nsg_aks_app_id" {
  value = azurerm_network_security_group.app_pool.id
}

output "nsg_cron_job_id" {
  value = azurerm_network_security_group.cron_job_pool.id
}

output "nsg_kafka_id" {
  value = azurerm_network_security_group.kafka.id
}

output "nsg_database_id" {
  value = azurerm_network_security_group.database.id
}