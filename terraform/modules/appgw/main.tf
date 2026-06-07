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

data "terraform_remote_state" "nginx" {
  backend = "azurerm"
  config = {
    resource_group_name  = "terraform-state"
    storage_account_name = "9082400test"
    container_name       = "082400container"
    key                  = "nginx.tfstate"
  }
}

data "terraform_remote_state" "services" {
  backend = "azurerm"
  config = {
    resource_group_name  = "terraform-state"
    storage_account_name = "9082400test"
    container_name       = "082400container"
    key                  = "services.tfstate"
  }
}


resource "azurerm_public_ip" "appgw" {
  name                = var.appgw_pip_name
  location            = data.terraform_remote_state.network.outputs.location
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_web_application_firewall_policy" "main" {
  name                = var.waf_policy_name
  location            = data.terraform_remote_state.network.outputs.location
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    max_request_body_size_in_kb = 128
    file_upload_limit_in_mb     = 100
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
    managed_rule_set {
      type    = "Microsoft_BotManagerRuleSet"
      version = "1.0"
    }
  }

}


locals {
  backend_address_pool_name      = "beap-main"
  frontend_port_name_http        = "feport-http"
  frontend_port_name_https       = "feport-https"
  frontend_ip_configuration_name = "feip-main"
  http_setting_name              = "be-htst-main"
  listener_name_http             = "lst-http"
  listener_name_https            = "lst-https"
  redirect_configuration_name    = "rdrcfg-http-to-https"
  routing_rule_name_http         = "rqrt-http"
  routing_rule_name_https        = "rqrt-https"
  ssl_certificate_name           = "ssl-cert-main"
}

resource "azurerm_application_gateway" "main" {
  name                = var.appgw_name
  location            = data.terraform_remote_state.network.outputs.location
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  zones               = ["1", "2", "3"]
  firewall_policy_id  = azurerm_web_application_firewall_policy.main.id

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id =  data.terraform_remote_state.network.outputs.appgw_subnet_id
  }

  # ── Frontend ──
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  frontend_port {
    name = local.frontend_port_name_http
    port = 80
  }

  frontend_port {
    name = local.frontend_port_name_https
    port = 443
  }

  # ── Backend ──
  backend_address_pool {
    name = local.backend_address_pool_name
    ip_addresses = [data.terraform_remote_state.nginx.outputs.nginx_internal_ip]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "health-probe"
  }

  # ── Health Probe ──
  probe {
    name                = "health-probe"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    protocol            = "Http"
    port                = 80
    path                = "/"
    host="127.0.0.1"

    match {
      status_code = ["200-399"]
    }
  }

  # ── HTTP Listener → redirect sang HTTPS ──
  http_listener {
    name                           = local.listener_name_http
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name_http
    protocol                       = "Http"
  }

  # ── HTTPS Listener ──
  http_listener {
    name                           = local.listener_name_https
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name_https
    protocol                       = "Https"
    ssl_certificate_name           = local.ssl_certificate_name
    firewall_policy_id             = azurerm_web_application_firewall_policy.main.id
  }

  # ── SSL Certificate (lấy từ Key Vault) ──
  ssl_certificate {
    name                = local.ssl_certificate_name
    key_vault_secret_id = data.terraform_remote_state.services.outputs.ssl_cert_secret_id
  }

  # ── SSL Policy ──
  ssl_policy {
    policy_type          = "Predefined"
    policy_name          = "AppGwSslPolicy20220101"
  }

  # ── Redirect HTTP → HTTPS ──
  redirect_configuration {
    name                 = local.redirect_configuration_name
    redirect_type        = "Permanent"
    target_listener_name = local.listener_name_https
    include_path         = true
    include_query_string = true
  }

  # ── Routing Rules ──
  request_routing_rule {
    name                        = local.routing_rule_name_http
    rule_type                   = "Basic"
    priority                    = 100
    http_listener_name          = local.listener_name_http
    redirect_configuration_name = local.redirect_configuration_name
  }

  request_routing_rule {
    name                       = local.routing_rule_name_https
    rule_type                  = "Basic"
    priority                   = 200
    http_listener_name         = local.listener_name_https
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  # ── Identity để đọc cert từ Key Vault ──
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.appgw.id]
  }

}

resource "azurerm_user_assigned_identity" "appgw" {
  name                = var.appgw_identity_name
  location            = data.terraform_remote_state.network.outputs.location
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
}

resource "azurerm_role_assignment" "appgw_keyvault" {
  principal_id         = azurerm_user_assigned_identity.appgw.principal_id
  role_definition_name = "Key Vault Secrets User"
  scope                = data.terraform_remote_state.services.outputs.keyvault_id
}
