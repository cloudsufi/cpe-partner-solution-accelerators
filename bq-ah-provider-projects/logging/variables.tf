variable "central_logging_project_id" {
  description = "Project ID for centralized logging"
  type        = string
  default     = "bqprovpr-bqah-central-logging"
}

variable "region" {
  description = "BigQuery dataset region"
  type        = string
}

variable "billing_account_id" {
  description = "Billing Account ID"
  type        = string
}

# variable "log_filter" {
#   description = "Log filter to apply"
#   default     = "resource.type=bigquery_project"
# }


variable "provider_managed_projects" {
  description = "Map of provider managed projects"
  type        = any
  default     = {}
}


variable "bq_dataset_writer_role" {
  description = "IAM role to allow log sink to write to the BigQuery dataset"
  type        = string
  default     = "roles/bigquery.dataEditor"
}

variable "bq_job_user_role" {
  description = "IAM role to allow logging service account to run BigQuery jobs"
  type        = string
  default     = "roles/bigquery.jobUser"
}
