variable "firewall_public_ip_name" {
    description = "Name of the firewall public IP"
    type        = string
    default     = "firewall-public-ip"
}
variable "bastion_public_ip_name" {
    description = "Name of the bastion public IP"
    type        = string
    default     = "bastion-public-ip"
}
variable "bastion_name" {
    description = "Name of the bastion host"
    type        = string        
    default     = "bastion-host"
}
variable "route_table_name" {
    description = "Name of the route table for spoke subnet"
    type        = string
    default     = "spoke-route-table"           

}
variable "route_name" {
    description = "Name of the route to firewall"
    type        = string
    default     = "route-to-firewall"
}


//
variable "firewall_name" {
    description = "Name of the Azure Firewall"
    type        = string
    default     = "azure-firewall"
}  
variable "firewall_policy_name" {
    description = "Name of the Azure Firewall Policy"
    type        = string
    default     = "azure-firewall-policy"   
  
}
variable "firewall_policy_rule_collection_group_name" {
    description = "Name of the Firewall Policy Rule Collection Group"
    type        = string
    default     = "firewall-policy-rule-collection-group"
  
}
