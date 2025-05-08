resource "google_project_service" "bq_api" {
  service = "bigquery.googleapis.com"
  project = google_project.central_logging.project_id
}

resource "google_project_service" "logging_api" {
  service = "logging.googleapis.com"
  project = google_project.central_logging.project_id
}

resource "google_project" "central_logging" {
  name       = "central-logging"
  project_id = var.central_logging_project_id
  folder_id  = var.folder_id_root
  billing_account = var.billing_account_id
}

resource "google_bigquery_dataset" "central_logs" {
  dataset_id                  = "central_logs"
  project                     = google_project.central_logging.project_id
  location                    = var.region
  delete_contents_on_destroy = true
}

resource "google_bigquery_dataset_iam_member" "log_writer_access" {
  project = google_project.central_logging.project_id
  dataset_id = google_bigquery_dataset.central_logs.dataset_id
  role       = "roles/bigquery.dataEditor"
  member = "serviceAccount:service-${google_project.central_logging.number}@gcp-sa-logging.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "job_user_access" {
  project = google_project.central_logging.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:service-${google_project.central_logging.number}@gcp-sa-logging.iam.gserviceaccount.com"
}

resource "google_logging_project_sink" "route_to_central" {
  name        = "route-to-central-logging"
  project     = google_project.central_logging.project_id
  destination = "bigquery.googleapis.com/projects/${google_project.central_logging.project_id}/datasets/${google_bigquery_dataset.central_logs.dataset_id}"
  # filter      = var.log_filter

  bigquery_options {
    use_partitioned_tables = true
  }

  unique_writer_identity = true
}

resource "google_bigquery_dataset_iam_member" "sink_writer" {
  project    = google_project.central_logging.project_id
  dataset_id = google_bigquery_dataset.central_logs.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.route_to_central.writer_identity
}