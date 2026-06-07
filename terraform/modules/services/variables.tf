// fake 

variable "acr_name"{
    description = "Name of the Azure Container Registry"
    type        = string
    default = "acr808502532"
}

# variable "kafka_vm_admin_username"{
#     description = "Username for the Kafka VM admin user"
#     type        = string 
#     default = "kafkaadmin"   
# }

variable "keyvault_name" {
    description = "Name of the Azure Key Vault"
    type        = string
    default     = "keyvault280840523"
  
}
variable "postgresql_name" {
    description = "Name of the Azure PostgreSQL Flexible Server"
    type        = string
    default     = "postgresqlname"
}
variable "postgresql_admin_login" {
    description = "Admin username for the Azure PostgreSQL Flexible Server"
    type        = string
    default     = "pgadmin"
}
