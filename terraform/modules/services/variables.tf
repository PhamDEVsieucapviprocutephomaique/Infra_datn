// fake 

variable "acr_name"{
    description = "Name of the Azure Container Registry"
    type        = string
    default = "acr_name"
}

variable "kafka_vm_admin_username"{
    description = "Username for the Kafka VM admin user"
    type        = string 
    default = "kafkaadmin"   
}
variable "kafka_vm_ssh_public_key"{
    description = "SSH public key for the Kafka VM admin user"
    type        = string
    # default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7..."  fake
}

variable "keyvault_name" {
    description = "Name of the Azure Key Vault"
    type        = string
    default     = "keyvault_name"
  
}
variable "postgresql_name" {
    description = "Name of the Azure PostgreSQL Flexible Server"
    type        = string
    default     = "postgresql_name"
}
variable "postgresql_admin_login" {
    description = "Admin username for the Azure PostgreSQL Flexible Server"
    type        = string
    default     = "pgadmin"
}
variable "postgresql_admin_password" {
    description = "Admin password for the Azure PostgreSQL Flexible Server"
    type        = string   
    default     = "P@ssw0rd1234"
}   
