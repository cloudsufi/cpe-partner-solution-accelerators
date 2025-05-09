variable "central_logging_project_id" {
  description = "Project ID for centralized logging"
  default     = "bqprovpr-bqah-central-logging"
}

variable "billing_account_id" {
  description = "Billing account ID"
  default     = "01862A-CCBDDA-E513DC"
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
  default     = "24112046497"
}

variable "provider_managed_projects" {
  description = "Map of provider managed projects"
  type = map(object({
    project_id = string
  }))
  default = {
    janes = {
      project_id = "bqprovpr-0819c0-cx-janes"
    }
    johns = {
      project_id = "bqprovpr-0819c0-cx-johns"
    }
  }
}

variable "folder_id_cx" {
  description = "Folder ID of customer projects"
  default     = "56100916370"
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
