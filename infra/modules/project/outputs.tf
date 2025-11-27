output "email_vm_traffic_sa" {
  description = "Service Account for the traffic VM."
  value       = google_service_account.sa_vm_traffic.email
}

output "email_dataflow_worker_sa" {
  description = "Service Account for Dataflow Workers."
  value       = google_service_account.sa_dataflow_worker.email
}
