resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com",
    "dataflow.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-api.googleapis.com",
    "pubsub.googleapis.com"
  ])

  project                    = var.project_id
  service                    = each.key
  disable_on_destroy         = false
  disable_dependent_services = false
}

# ----------------------------------------------------
# 1. Service Accounts (SAs)
# ----------------------------------------------------

# A. SA for the traffic-generating VM
resource "google_service_account" "sa_vm_traffic" {
  project      = var.project_id
  account_id   = "sa-traffic-generator"
  display_name = "SA para VM Generadora de Tráfico"
  depends_on   = [google_project_service.services]
}

# B. SA for Dataflow Workers
resource "google_service_account" "sa_dataflow_worker" {
  project      = var.project_id
  account_id   = "sa-dataflow-worker"
  display_name = "SA para Workers de Dataflow"
  depends_on   = [google_project_service.services]
}

# ----------------------------------------------------
# 2. IAM (Roles and Permissions)
# ----------------------------------------------------
data "google_project" "current" {
  project_id = var.project_id
}

locals {
  # Service Agent for Dataflow 
  dataflow_service_agent_sa = "service-${data.google_project.current.number}@dataflow-service-producer-prod.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "iam_dataflow_service_agent" {
  project    = var.project_id
  role       = "roles/dataflow.serviceAgent"
  member     = "serviceAccount:${local.dataflow_service_agent_sa}"
  depends_on = [google_service_account.sa_dataflow_worker]
}

resource "google_project_iam_member" "iam_df_worker_role" {
  project    = var.project_id
  role       = "roles/dataflow.worker"
  member     = "serviceAccount:${google_service_account.sa_dataflow_worker.email}"
  depends_on = [google_project_service.services]
}

resource "google_project_iam_member" "iam_df_bq_editor" {
  project    = var.project_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.sa_dataflow_worker.email}"
  depends_on = [google_project_service.services]
}

resource "google_project_iam_member" "iam_df_gcs_admin" {
  project    = var.project_id
  role       = "roles/storage.objectAdmin"
  member     = "serviceAccount:${google_service_account.sa_dataflow_worker.email}"
  depends_on = [google_project_service.services]
}

resource "google_project_iam_member" "iam_vm_gcs_creator" {
  project    = var.project_id
  role       = "roles/storage.objectCreator"
  member     = "serviceAccount:${google_service_account.sa_vm_traffic.email}"
  depends_on = [google_project_service.services]
}

resource "google_project_iam_member" "iam_vm_network_user" {
  project    = var.project_id
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${google_service_account.sa_vm_traffic.email}"
  depends_on = [google_project_service.services]
}
