# Centralized Logging with BigQuery in GCP

This Terraform module provisions a centralized logging architecture using **Google Cloud Platform (GCP)** services. It is designed to collect logs from customer-managed projects and route them to a central **BigQuery** dataset for analysis and storage.

---

## Features

- Provisions a central GCP project under the **provider projects' root folder** to serve as the logging hub.
- Enables essential GCP services—**BigQuery** and **Cloud Logging**—in the central logging project.
- Creates a centralized **BigQuery dataset** to store aggregated logs.
- Configures a **folder-level logging sink** in the **consumer projects' folder**, routing logs to the central BigQuery dataset in the logging project.
- Grants necessary **IAM permissions** to the sink’s service account to allow writing logs to BigQuery.
- Authorizes logging service accounts to execute **BigQuery jobs** within the central project.

---

## Architecture

```
+-------------------------+         +------------------------+
| Customer Projects       |         | Central Logging Project|
| (var.provider_managed_  |  --->   |  - BigQuery Dataset    |
|  projects)              |         |  - Logging Sink Target |
+-------------------------+         +------------------------+
         |
         | Logs at folder level
         v
+---------------------------------------------+
| google_logging_folder_sink                  |
| - Sends logs to BigQuery dataset            |
| - Uses partitioned tables                   |
+---------------------------------------------+
```

---

## Requirements

- Terraform >= 1.3
- GCP credentials with appropriate permissions
- Folder structure and project outputs via `terraform_remote_state`

---

## Inputs

| Name                        | Description                                                | Type   | Required |
|-----------------------------|------------------------------------------------------------|--------|----------|
| `provider_managed_projects` | Map of project identifiers for customer-managed projects   | map    | yes      |
| `central_logging_project_id`| Project ID for the central logging project                 | string | yes      |
| `billing_account_id`        | Billing account to associate with the central project      | string | yes      |
| `region`                    | Region for the BigQuery dataset                            | string | yes      |
| `bq_dataset_writer_role`    | IAM role for dataset writer (e.g., roles/bigquery.dataEditor)| string | yes   |
| `bq_job_user_role`          | IAM role to run BQ jobs (e.g., roles/bigquery.jobUser)     | string | yes      |
| `log_filter`                | (Optional) Log filter for sink                             | string | no       |

---

## Outputs

None defined explicitly, but this module provisions:

- A centralized logging project
- A BigQuery dataset `central_logs`
- IAM bindings for the sink writer and job user

---

## Usage

```hcl
module "logging" {
  source = "./logging"

  provider_managed_projects = {
    "project1" = "project-1-id"
    "project2" = "project-2-id"
  }

  central_logging_project_id = "XXXXXX-XXXXXX-XXXXXX"
  billing_account_id         = "XXXXXX-XXXXXX-XXXXXX"
  region                     = "us-central1"
  bq_dataset_writer_role     = "roles/bigquery.dataEditor"
  bq_job_user_role           = "roles/bigquery.jobUser"
}
```

---

## Notes

- The module assumes the folder structure and project metadata are being fetched via `terraform_remote_state`.
- The dataset is set to delete contents on destroy, suitable for dev/test environments.

---
