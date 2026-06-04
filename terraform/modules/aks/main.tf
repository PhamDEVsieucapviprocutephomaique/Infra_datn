data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "terraform-state"
    storage_account_name = "9082400test"
    container_name       = "082400container"
    key                  = "network.tfstate"
  }
}

data "terraform_remote_state" "firewall" {
  backend = "azurerm"
  config = {
    resource_group_name  = "terraform-state"
    storage_account_name = "9082400test"
    container_name       = "082400container"
    key                  = "firewall.tfstate"
  }
}

resource "azurerm_user_assigned_identity" "aks" {
  name                = var.aks_identity_name
  location            = data.terraform_remote_state.network.outputs.location
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
}


resource "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_name
  location            = data.terraform_remote_state.network.outputs.location
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  dns_prefix          = var.aks_dns_prefix 
  kubernetes_version  = var.kubernetes_version
  sku_tier           = "Free"
    default_node_pool {
        name                         = "system"
        node_count                   = 1
        vm_size                      = "Standard_B2s"
        vnet_subnet_id               = data.terraform_remote_state.network.outputs.system_pool_subnet_id
        # auto_scaling_enabled         = true
        # min_count                    = 1
        # max_count                    = 1
        os_disk_size_gb              = 30
        os_disk_type                 = "Managed"
        only_critical_addons_enabled = true
        upgrade_settings {
        max_surge = "33%"
        }

    }
    identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }
    network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "azure"  
    load_balancer_sku   = "standard"
    outbound_type       = "userDefinedRouting"
    dns_service_ip      = "172.16.0.10"
    service_cidr        = "172.16.0.0/16"
  }
  // identity 
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  azure_policy_enabled             = true
  http_application_routing_enabled = false

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }
  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.main.id
    msi_auth_for_monitoring_enabled = true
  }
   maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    interval    = 1
    day_of_week = "Sunday"
    start_time  = "02:00"
    utc_offset  = "+07:00"
    duration    = 4
  }

  maintenance_window_node_os {
    frequency   = "Weekly"
    interval    = 1
    day_of_week = "Saturday"
    start_time  = "02:00"
    utc_offset  = "+07:00"
    duration    = 4
  }

  automatic_upgrade_channel = "stable"
  node_os_upgrade_channel   = "NodeImage"
}


//  ko đủ qouta , hàng free học tập nên chịu =))

resource "azurerm_kubernetes_cluster_node_pool" "app" {
  name                  = var.aks_app_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_B2s"
  vnet_subnet_id        = data.terraform_remote_state.network.outputs.app_pool_subnet_id
  node_count = 1
  # auto_scaling_enabled  = true
  # min_count             = 1
  # max_count             = 1
  os_disk_size_gb       = 30
  os_disk_type          = "Managed"
  os_type               = "Linux"
  node_labels = {
    "pool" = "app"
  }
  upgrade_settings {
    max_surge = "33%"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "cron_job" {
  name                  = var.aks_cron_job_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_B2s"
  vnet_subnet_id        = data.terraform_remote_state.network.outputs.cron_job_pool_subnet_id
  node_count = 1
  # auto_scaling_enabled  = true
  # min_count             = 1
  # max_count             = 1
  os_disk_size_gb       = 30
  os_disk_type          = "Managed"
  os_type               = "Linux"
  node_labels = {
    "pool" = "cronjob"
  }
  upgrade_settings {
    max_surge = "33%"
  }
}

# Log Analytics Workspace

resource "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_name
  location            = data.terraform_remote_state.network.outputs.location
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
resource "azurerm_log_analytics_solution" "container_insights" {
  solution_name         = "ContainerInsights"
  location              = data.terraform_remote_state.network.outputs.location
  resource_group_name   = data.terraform_remote_state.network.outputs.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

# Role Assignment - AKS identity đọc được ACR 
data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "aks_network" {
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
  role_definition_name = "Network Contributor"
  # Dùng data source thay vì biến
  scope                = data.azurerm_subscription.current.id
}