variable "project_id" {
  description = "GCP Project ID where all resources will be provisioned"
  type        = string
  default     = "traffic-generator-479416"
}

variable "region" {
  description = "GCP region."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone for VM."
  type        = string
  default     = "us-central1-a"
}

variable "vm_machine_type" {
  description = "Machine type for the traffic generator VM."
  type        = string
  default     = "e2-medium"
}
