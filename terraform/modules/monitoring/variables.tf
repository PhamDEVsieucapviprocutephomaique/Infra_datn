variable "action_group_name" {
  default = "ag-devops"
}

variable "alert_email" {
  description = "Email nhận alert"
}

variable "dashboard_name" {
  default = "dashboard-aks"
}

variable "tags" {
  default = {
    environment = "production"
    managed_by  = "terraform"
  }
}