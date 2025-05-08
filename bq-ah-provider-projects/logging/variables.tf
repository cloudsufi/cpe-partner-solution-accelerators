variable "central_logging_project_id" {
  description = "Project ID for centralized logging"
  default     = "bqprovpr-bqah-central-logging"
}

variable "billing_account_id" {
  description = "Billing account ID"
  default = "01862A-CCBDDA-E513DC"
}

variable "region" {
  description = "BigQuery dataset region"
  default     = "us-central1"
}

# variable "log_filter" {
#   description = "Log filter to apply"
#   default     = "resource.type=bigquery_project"
# }

variable "folder_id_root" {
  description = "Folder id of the root project"
  default = "24112046497"
}