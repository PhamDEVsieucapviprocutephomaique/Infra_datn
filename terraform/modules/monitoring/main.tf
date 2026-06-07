
data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "terraform-state"
    storage_account_name = "9082400test"
    container_name       = "082400container"
    key                  = "network.tfstate"
  }
}


data "terraform_remote_state" "aks" {
  backend = "azurerm"
  config = {
    resource_group_name  = "terraform-state"
    storage_account_name = "9082400test"
    container_name       = "082400container"
    key                  = "aks.tfstate"
  }
}


resource "azurerm_monitor_action_group" "main" {
  name                = var.action_group_name
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  short_name          = "alert-main"

  email_receiver {
    name                    = "devops-team"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }

}

resource "azurerm_monitor_metric_alert" "node_cpu" {
  name                = "alert-node-cpu-high"
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  scopes              = [data.terraform_remote_state.aks.outputs.aks_id]
  description         = "Node CPU vượt 80%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_cpu_usage_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "node_memory" {
  name                = "alert-node-memory-high"
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  scopes              = [data.terraform_remote_state.aks.outputs.aks_id]
  description         = "Node memory vượt 80%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_memory_working_set_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}
resource "azurerm_monitor_metric_alert" "pod_restart" {
  name                = "alert-pod-restart"
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  scopes              = [data.terraform_remote_state.aks.outputs.aks_id]
  description         = "Pod restart quá nhiều"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "kube_pod_status_ready"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "diag-aks"
  target_resource_id         = data.terraform_remote_state.aks.outputs.aks_id
  log_analytics_workspace_id = data.terraform_remote_state.aks.outputs.log_analytics_workspace_id

  enabled_log {
    category = "kube-apiserver"
  }

  enabled_log {
    category = "kube-audit"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "kube-scheduler"
  }

  enabled_log {
    category = "cluster-autoscaler"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}


resource "azurerm_portal_dashboard" "main" {
  name                = var.dashboard_name
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  location            = data.terraform_remote_state.network.outputs.location
  tags                = var.tags

  dashboard_properties = jsonencode({
    lenses = {}
    metadata = {
      model = {}
    }
  })
}