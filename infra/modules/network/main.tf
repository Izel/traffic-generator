resource "google_compute_network" "vpc_traffic" {
  name                    = "vpc-traffic-generator"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_network" "vpc_dataflow" {
  name                    = "vpc-dataflow-processing"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "traffic_subnet" {
  name          = "traffic-generator-subnet"
  ip_cidr_range = "10.10.1.0/24" # Rango único para la VM
  region        = var.region
  network       = google_compute_network.vpc_traffic.name
  project       = var.project_id
}

resource "google_compute_subnetwork" "dataflow_subnet" {
  name          = "dataflow-processing-subnet"
  ip_cidr_range = "10.10.2.0/24" # Rango único para Dataflow
  region        = var.region
  network       = google_compute_network.vpc_dataflow.name
  project       = var.project_id
}

resource "google_compute_network_peering" "peering_traffic_to_dataflow" {
  name         = "peering-traffic-to-dataflow"
  network      = google_compute_network.vpc_traffic.self_link
  peer_network = google_compute_network.vpc_dataflow.self_link
}

resource "google_compute_network_peering" "peering_dataflow_to_traffic" {
  name         = "peering-dataflow-to-traffic"
  network      = google_compute_network.vpc_dataflow.self_link
  peer_network = google_compute_network.vpc_traffic.self_link
}

# ---------------------------------------------------------------------
# Firewall rule #1: Allow traffic out from VM to Peer network (EGRESS) 
# ---------------------------------------------------------------------
resource "google_compute_firewall" "allow_vm_egress_to_dataflow" {
  project            = var.project_id
  name               = "allow-vm-egress-to-dataflow"
  network            = google_compute_network.vpc_traffic.name # Aplicada a la VPC de la VM
  direction          = "EGRESS"
  target_tags        = ["traffic-generator-vm"]
  destination_ranges = ["10.128.0.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
}

# ------------------------------------------------------------
# Firewall Rule #2: Allow traffic in to Dataflow (INGRESS)
# ------------------------------------------------------------
resource "google_compute_firewall" "allow_dataflow_ingress_from_vm_vpc" {
  project       = var.project_id
  name          = "allow-dataflow-ingress-from-vm"
  network       = google_compute_network.vpc_dataflow.name
  direction     = "INGRESS"
  target_tags   = ["dataflow-worker"]
  source_ranges = ["10.128.0.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
}
