output "traffic_subnet_self_link" {
  description = "Self Link for traffic subnet."
  value       = google_compute_subnetwork.traffic_subnet.self_link
}

output "dataflow_subnet_self_link" {
  description = "Self Link for Dataflow subnet."
  value       = google_compute_subnetwork.dataflow_subnet.self_link
}
