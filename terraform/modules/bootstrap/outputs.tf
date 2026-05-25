output "storage_account_name" {
    value = azurerm_storage_account.state.name
}

output "storage_container_name" {
    value = azurerm_storage_container.state.name
}
output "resource_group_name" {
    value = azurerm_resource_group.state.name
}
