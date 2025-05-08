# Get project data for all customer-managed projects
data "google_project" "cx_projects" {
  for_each   = var.provider_managed_projects
  project_id = each.value.project_id
}

# Central provider logging project
resource "google_project" "central_logging" {
  name            = "central-logging"
  project_id      = var.central_logging_project_id
  folder_id       = var.folder_id_root
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

# Enable APIs in all customer projects
resource "google_project_service" "logging_api_customers" {
  for_each = var.provider_managed_projects
  service  = "logging.googleapis.com"
  project  = each.value.project_id
}

resource "google_project_service" "bq_api_customers" {
  for_each = var.provider_managed_projects
  service  = "bigquery.googleapis.com"
  project  = each.value.project_id
}

# BigQuery dataset in central logging project
resource "google_bigquery_dataset" "central_logs" {
  dataset_id                 = "central_logs"
  project                    = google_project.central_logging.project_id
  location                   = var.region
  delete_contents_on_destroy = true
}

# Logging sink in each customer project
resource "google_logging_project_sink" "route_to_central" {
  for_each    = var.provider_managed_projects
  name        = "route-to-central-logging"
  project     = each.value.project_id
  destination = "bigquery.googleapis.com/projects/${google_project.central_logging.project_id}/datasets/${google_bigquery_dataset.central_logs.dataset_id}"

  bigquery_options {
    use_partitioned_tables = true
  }

  unique_writer_identity = true
  # Optional: filter = "resource.type=gce_instance"
}

# Grant sink writer identity access to the central dataset
resource "google_bigquery_dataset_iam_member" "sink_writer" {
  for_each   = var.provider_managed_projects
  dataset_id = google_bigquery_dataset.central_logs.dataset_id
  project    = google_bigquery_dataset.central_logs.project
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.route_to_central[each.key].writer_identity
}

# Allow logging service account in each customer project to run BQ jobs
resource "google_project_iam_member" "customer_job_user" {
  for_each = var.provider_managed_projects
  project  = google_project.central_logging.project_id
  role     = "roles/bigquery.jobUser"
  member   = "serviceAccount:service-${data.google_project.cx_projects[each.key].number}@gcp-sa-logging.iam.gserviceaccount.com"
}
