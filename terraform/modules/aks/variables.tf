variable "aks_identity_name" {
    description = "Name of the AKS Managed Identity"
    type        = string
    default     = "aks-managed-identity"


}
variable "aks_app_pool_name" {
    description = "Name of the AKS App Node Pool"
    type        = string
    default     = "app-pool"
}
variable "aks_cron_job_pool_name" {
    description = "Name of the AKS Cron Job Node Pool"
    type        = string
    default     = "cron-job-pool"
}
variable "log_analytics_name" {
    description = "Name of the Log Analytics Workspace"
    type        = string
    default     = "aks-log-analytics"
}  

variable "aks_name"{
    description = "Name of the AKS Cluster"
    type        = string
    default     = "aks-cluster"
}
variable "aks_dns_prefix"{
    description = "DNS prefix for the AKS Cluster"
    type        = string
    default     = "aksdns"
}
variable "kubernetes_version" {
    description = "Kubernetes version for the AKS Cluster"
    type        = string
    default     = "1.32"
}