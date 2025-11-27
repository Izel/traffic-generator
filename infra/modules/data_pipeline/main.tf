# ----------------------------------------------------
# BigQuery dataset and table for traffic data sink
# ----------------------------------------------------
resource "google_bigquery_dataset" "traffic_sink_dataset" {
  dataset_id = "traffic_analysis_data"
  project    = var.project_id
  location   = var.region
}

resource "google_bigquery_table" "traffic_sink_table" {
  dataset_id          = google_bigquery_dataset.traffic_sink_dataset.dataset_id
  table_id            = "raw_traffic_data"
  project             = var.project_id
  deletion_protection = false
}

# ----------------------------------------------------
# Stagging Bucket for Dataflow
# ----------------------------------------------------
resource "google_storage_bucket" "dataflow_staging" {
  # Creamos el bucket usando el nombre pasado por la variable
  name          = var.dataflow_staging_gcs_bucket
  location      = var.region
  force_destroy = true
  project       = var.project_id
}
