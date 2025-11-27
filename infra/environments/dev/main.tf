provider "google" {
  project = var.project_id # Usa la variable definida en environments/dev/variables.tf
  region  = var.region
}

data "google_project" "current" {
  project_id = var.project_id
}

locals {
  # Default SA for Compute Engine
  compute_default_sa = "${data.google_project.current.number}-compute@developer.gserviceaccount.com"
  # Dataflow Service Agent email 
  dataflow_service_agent_sa = "service-${data.google_project.current.number}@dataflow-service-producer-prod.iam.gserviceaccount.com"
}

resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com",
    "dataflow.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "storage.googleapis.com"
  ])
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

# Provide IAM provileges to SA
resource "google_project_iam_member" "dataflow_agent_role" {
  project    = var.project_id
  role       = "roles/dataflow.serviceAgent"
  member     = "serviceAccount:${local.dataflow_service_agent_sa}"
  depends_on = [module.project_setup]
}

resource "google_project_iam_member" "dataflow_bq_writer" {
  project    = var.project_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${local.dataflow_service_agent_sa}"
  depends_on = [module.project_setup]
}

# ----------------------------------------------------
# Module calls
# ----------------------------------------------------
module "project_setup" {
  source     = "../../modules/project"
  project_id = var.project_id
}

module "network" {
  source     = "../../modules/network"
  project_id = var.project_id
  region     = var.region
  depends_on = [module.project_setup]
}

module "compute" {
  source                   = "../../modules/compute"
  project_id               = var.project_id
  region                   = var.region
  zone                     = var.zone
  vm_machine_type          = var.vm_machine_type
  traffic_subnet_self_link = module.network.traffic_subnet_self_link
  vm_service_account_email = module.project_setup.email_vm_traffic_sa
  depends_on               = [module.network]
}

module "data_pipeline" {
  source                      = "../../modules/data_pipeline"
  project_id                  = var.project_id
  region                      = var.region
  dataflow_subnet_self_link   = module.network.dataflow_subnet_self_link
  dataflow_worker_sa_email    = module.project_setup.email_dataflow_worker_sa
  dataflow_staging_gcs_bucket = "${var.project_id}-df-staging-dev"
  depends_on = [
    module.project_setup,
    module.network
  ]
}
