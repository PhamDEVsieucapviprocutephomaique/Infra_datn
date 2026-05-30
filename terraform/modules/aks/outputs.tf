output "aks_name" {
    description = "Name of the AKS Cluster"
    value       = azurerm_kubernetes_cluster.main.name
}
output "aks_identity_id" {
    description = "ID of the AKS Managed Identity"
    value       = azurerm_user_assigned_identity.aks_identity.id
}
output "aks_identity_client_id" {
    description = "Client ID of the AKS Managed Identity"
    value       = azurerm_user_assigned_identity.aks_identity.client_id
}
output "aks_identity_principal_id" {
    description = "Principal ID of the AKS Managed Identity"
    value       = azurerm_user_assigned_identity.aks_identity.principal_id
}
output "aks_app_pool_name" {
    description = "Name of the AKS App Node Pool"
    value       = azurerm_kubernetes_cluster_node_pool.app.name
}
output "aks_cron_job_pool_name" {
    description = "Name of the AKS Cron Job Node Pool"
    value       = azurerm_kubernetes_cluster_node_pool.cron_job.name
}
output "log_analytics_workspace_id" {
    description = "ID of the Log Analytics Workspace"   
    value       = azurerm_log_analytics_workspace.main.id
}
output "log_analytics_workspace_name" {
    description = "Name of the Log Analytics Workspace"
    value       = azurerm_log_analytics_workspace.main.name
}
output "kubelet_identity_object_id"{
    description = "Object ID of the AKS Kubelet Identity"
    value       = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}