resource "google_compute_instance" "traffic_generator_vm" {
  name         = "traffic-generator-vm"
  machine_type = var.vm_machine_type
  zone         = var.zone
  project      = var.project_id
  tags         = ["traffic-generator-vm"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = var.traffic_subnet_self_link
  }

  service_account {
    email  = var.vm_service_account_email
    scopes = ["cloud-platform"]
  }
}

