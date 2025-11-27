variable "project_id" {
  description = "GCP Project ID where all resources will be provisioned."
  type        = string
}

variable "region" {
  description = "GCP project region."
  type        = string
}

variable "zone" {
  description = "GCP project zone."
  type        = string
}

variable "vm_machine_type" {
  description = "Machine type for the traffic generator VM."
  type        = string
}

variable "vm_service_account_email" {
  description = "Service account email for the traffic generator VM."
  type        = string
}

variable "traffic_subnet_self_link" {
  description = "Subnet Self Link for the traffic-generator VM."
  type        = string
}
