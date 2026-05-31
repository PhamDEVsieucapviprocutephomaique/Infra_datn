variable "appgw_name" {
    description = "Name of the Application Gateway"
    type        = string
    default     = "appgw_name"
}
variable "ssl_cert_key_vault_secret_id" {
    description = "ID of the Key Vault secret containing the SSL certificate for App Gateway"
    type        = string
    default = data.terraform_remote_state.services.outputs.ssl_cert_secret_id
}
variable "appgw_pip_name"{
    description = "Name of the Public IP for the Application Gateway"
    type        = string
    default     = "appgw-pip"
}
variable "appgw_sku_name" {
    description = "SKU name for the Application Gateway (e.g., Standard_v2)"
    type        = string
    default     = "Standard_v2"
}
variable "appgw_sku_tier" {
    description = "SKU tier for the Application Gateway (e.g., Standard_v2)"
    type        = string
    default     = "Standard_v2"
}
variable "appgw_capacity" {
    description = "Instance count for the Application Gateway"
    type        = number
    default     = 2
}
variable "waf_policy_name" {
    description = "Name of the Web Application Firewall policy for the Application Gateway"
    type        = string
    default     = "appgw-waf-policy"
}
variable "appgw_identity_name"{
    description = "Name of the User Assigned Identity for the Application Gateway"
    type        = string
    default     = "appgw-identity"
}
variable "keyvault_id"{
    description = "ID of the Key Vault containing the SSL certificate for App Gateway"
    type        = string
    default = data.terraform_remote_state.services.outputs.keyvault_id
}
variable "aks_ingress_fqdn" {
  description = "FQDN của AKS Ingress Controller"
  type        = string
  default     = "aks-ingress.internal.cloudapp.net"
}