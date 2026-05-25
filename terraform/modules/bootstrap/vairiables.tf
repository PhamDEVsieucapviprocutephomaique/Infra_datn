variable "location" {
    description = "azure region"
    type        = string
    default    = "southeastasia"
}
variable "resource_group_name" {
    type       = string
    default    ="terraform-state"
}

variable "storage_account_name"{
    type       = string
    default    = "storage_account"
}
variable "storage_container" {
    type       = string
    default    = "storage_container"
}