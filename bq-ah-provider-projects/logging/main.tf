# Get project data for all customer-managed projects
data "google_project" "cx_projects" {
  for_each   = var.provider_managed_projects
  project_id = data.terraform_remote_state.consumer_projects.outputs.project_ids[each.key]
}

# Central provider logging project
resource "google_project" "central_logging" {
  name            = "central-logging"
  project_id      = var.central_logging_project_id
  folder_id       = data.terraform_remote_state.provider-org-create-projects-bootstrap.outputs.folder_id_root
  billing_account = var.billing_account_id
}

# Enable APIs in central project
resource "google_project_service" "central_bq_api" {
  service = "bigquery.googleapis.com"
  project = google_project.central_logging.project_id
}

resource "google_project_service" "central_logging_api" {
  service = "logging.googleapis.com"
  project = google_project.central_logging.project_id
}

# BigQuery dataset in central logging project
resource "google_bigquery_dataset" "central_logs" {
  dataset_id                 = "central_logs"
  project                    = google_project.central_logging.project_id
  location                   = var.region
  delete_contents_on_destroy = true
}

# Logging sink at folder level 
resource "google_logging_folder_sink" "route_to_central" {
  name        = "route-to-central-logging"
  folder      = data.terraform_remote_state.provider-org-create-projects-bootstrap.outputs.folder_id_cx
  destination = "bigquery.googleapis.com/projects/${google_project.central_logging.project_id}/datasets/${google_bigquery_dataset.central_logs.dataset_id}"
  bigquery_options {
    use_partitioned_tables = true
  }
  # Optional log filter
  # filter = var.log_filter 
}


# Grant sink writer identity access to the central dataset
resource "google_bigquery_dataset_iam_member" "sink_writer" {
  dataset_id = google_bigquery_dataset.central_logs.dataset_id
  project    = google_project.central_logging.project_id
  role       = var.bq_dataset_writer_role
  member     = google_logging_folder_sink.route_to_central.writer_identity
}


# Allow logging service account in each customer project to run BQ jobs
resource "google_project_iam_member" "customer_job_user" {
  project = google_project.central_logging.project_id
  role    = var.bq_job_user_role
  member  = google_logging_folder_sink.route_to_central.writer_identity
}
