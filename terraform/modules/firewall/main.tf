

data "terraform_remote_state" "network" {
  backend = "azurerm"

  config = {
    resource_group_name  = "terraform-state"
    storage_account_name = "storage_account"
    container_name       = "storage_container"
    key                  = "network.tfstate"
  }
}

resource "azurerm_public_ip" "firewall_public_ip" {
  name                = var.firewall_public_ip_name
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  location            = data.terraform_remote_state.network.outputs.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}



resource "azurerm_firewall_policy" "firewall_policy" {
  name                = var.firewall_policy_name
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  location            = data.terraform_remote_state.network.outputs.location
  sku                 ="Standard"
  threat_intelligence_mode = "Deny"

  dns {
    proxy_enabled = true # Bắt buộc bật để dùng FQDN hiệu quả và an toàn
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "main" {
  name               = var.firewall_policy_rule_collection_group_name
  firewall_policy_id = azurerm_firewall_policy.firewall_policy.id
  priority           = 100


  nat_rule_collection {
    name="dnat-inbound-to-aks"
    priority = 100
    action   = "Dnat"
    rule{
      name                = "allow-https-inbound"
      protocols           = ["TCP"]
      source_addresses    = ["*"] # Hoặc giới hạn IP của Cloudflare/WAF nếu có
      destination_address = azurerm_public_ip.firewall_public_ip.ip_address
      destination_ports   = ["443"]
      # IP Private của Internal Load Balancer (Ingress Controller) trong AKS
      translated_address  = var.aks_ingress_internal_ip 
      translated_port     = "443"
    }

  }
   network_rule_collection {
    name     = "aks-outbound-network"
    priority = 200
    action   = "Allow"

    rule {
      name                  = "allow-dns-ntp"
      source_addresses      = data.terraform_remote_state.network.outputs.spoke_vnet_address_space
      destination_addresses = ["*"]
      destination_ports     = ["53", "123"] 
      protocols             = ["UDP"]
    }
  }

application_rule_collection {
    name     = "aks-outbound-fqdn"
    priority = 300
    action   = "Allow"

    rule {
      name             = "allow-azure-core-services"
      source_addresses = data.terraform_remote_state.network.outputs.spoke_vnet_address_space
      protocols {
        type = "Https"
        port = 443
      }
      destination_fqdns = [
        "*.azurecr.io",             # Kéo Image từ Azure Container Registry
        "mcr.microsoft.com",        # Kéo Image core của Microsoft
        "*.data.mcr.microsoft.com",
        "*.blob.core.windows.net",  # Lưu trữ
        "*.vault.azure.net",        # Key Vault
        "management.azure.com",     # Azure API
        "login.microsoftonline.com" # Xác thực Entra ID
      ]
    }

    rule {
      name             = "allow-os-updates"
      source_addresses = data.terraform_remote_state.network.outputs.spoke_vnet_address_space
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      destination_fqdns = [
        "security.ubuntu.com",
        "azure.archive.ubuntu.com",
        "changelogs.ubuntu.com"
      ]
    }
  }
}

resource "azurerm_firewall" "main" {
  name                = var.firewall_name
  location            = data.terraform_remote_state.network.outputs.location
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.firewall_policy.id

  ip_configuration {
    name                 = "firewall-ipconfig"
    subnet_id            = data.terraform_remote_state.network.outputs.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.firewall_public_ip.id
  }
}

# LOGGING  Đẩy log về Log Analytics Workspace
# resource "azurerm_monitor_diagnostic_setting" "firewall_logs" {
#   name                       = "firewall-diagnostics"
#   target_resource_id         = azurerm_firewall.main.id
#   log_analytics_workspace_id = var.log_analytics_workspace_id # Cần truyền biến này vào

#   enabled_log {
#     category = "AzureFirewallApplicationRule"
#   }
#   enabled_log {
#     category = "AzureFirewallNetworkRule"
#   }
#   enabled_log {
#     category = "AzureFirewallNatRule"
#   }
#   enabled_log {
#     category = "AzureFirewallDnsProxy"
#   }
#   metric {
#     category = "AllMetrics"
#     enabled  = true
#   }
# }


resource "azurerm_public_ip" "bastion_public_ip" {
  name                = var.bastion_public_ip_name
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  location            = data.terraform_remote_state.network.outputs.location
  allocation_method   = "Static"
  sku                 = "Standard"
}


resource "azurerm_bastion_host" "main" {
  name                = var.bastion_name
  location            = data.terraform_remote_state.network.outputs.location
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  sku                 = "Standard"

  ip_configuration {
    name                 = "bastion-ipconfig"
    subnet_id            = data.terraform_remote_state.network.outputs.bastion_subnet_id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }
}


resource "azurerm_route_table" "spoke" {
  name                          = var.route_table_name
  location                      = data.terraform_remote_state.network.outputs.location
  resource_group_name           = data.terraform_remote_state.network.outputs.resource_group_name
  bgp_route_propagation_enabled = false
}


resource "azurerm_route" "to_firewall" {
  name                   = var.route_name
  resource_group_name    = data.terraform_remote_state.network.outputs.resource_group_name
  route_table_name       = azurerm_route_table.spoke.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.main.ip_configuration[0].private_ip_address
}

resource "azurerm_subnet_route_table_association" "aks_system" {
  subnet_id      = data.terraform_remote_state.network.outputs.system_pool_subnet_id
  route_table_id = azurerm_route_table.spoke.id
}

resource "azurerm_subnet_route_table_association" "aks_app" {
  subnet_id      = data.terraform_remote_state.network.outputs.app_pool_subnet_id
  route_table_id = azurerm_route_table.spoke.id
}

resource "azurerm_subnet_route_table_association" "cron_job" {
  subnet_id      = data.terraform_remote_state.network.outputs.cron_job_pool_subnet_id
  route_table_id = azurerm_route_table.spoke.id
}