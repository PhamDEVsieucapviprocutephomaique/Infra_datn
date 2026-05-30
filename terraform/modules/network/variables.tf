variable "resource_group_name" {
    description = "Name of the resource group to create"
    type        = string
    default     = "resource-group-main"
}
variable "location" {
    description = "Azure region where resources will be created"
    type        = string
    default     = "southeastasia"
}
variable "hub_vnet_name" {
    description = "Name of the hub virtual network"
    type        = string
    default     = "hub-vnet"
}
variable "spoke_vnet_name" {
    description = "Name of the spoke virtual network"
    type        = string
    default     = "spoke-vnet"
}
variable "hub_spoke" {
    description = "Name of the peering from hub to spoke"   
    type        = string
    default     = "hub-spoke"
}
variable "spoke_hub" {
    description = "Name of the peering from spoke to hub"
    type        = string
    default     = "spoke-hub"
}                      
variable "firewall_subnet_name" {
    description = "Name of the firewall subnet"
    type        = string
    default     = "firewall_subnet_name"
}
variable "bastion_subnet_name" {
    description = "Name of the bastion subnet"
    type        = string
    default     = "bastion_subnet_name"
}
variable "system_pool_subnet_name" {
    description = "Name of the system pool subnet"
    type        = string
    default     = "system-pool-subnet"
}
variable "app_pool_subnet_name" {
    description = "Name of the app pool subnet"
    type        = string
    default     = "app-pool-subnet"
}
variable "cron_job_pool_subnet_name" {
    description = "Name of the cron job pool subnet"
    type        = string
    default     = "cron-job-pool-subnet"
}
variable "kafka_subnet_name" {
    description = "Name of the Kafka subnet"
    type        = string
    default     = "kafka-subnet"
}
variable "database_subnet_name" {
    description = "Name of the database subnet"
    type        = string
    default     = "database-subnet"
}

