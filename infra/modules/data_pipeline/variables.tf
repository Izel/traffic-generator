variable "project_id" {
  description = "GCP Project ID where all resources will be provisioned."
  type        = string
}

variable "region" {
  description = "GCP project region."
  type        = string
}

variable "dataflow_subnet_self_link" {
  description = "Subnet Self Link to execute Dataflow workers."
  type        = string
}

variable "dataflow_worker_sa_email" {
  description = "Dataflow workers Service Account."
  type        = string
}

variable "dataflow_staging_gcs_bucket" {
  description = "GCS staging bucket for Dataflow."
  type        = string
}
