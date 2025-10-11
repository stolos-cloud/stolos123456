# GCP Compute Instance Module for Talos Nodes
# Uses official Talos GCP image and injects machine config via metadata

data "google_compute_network" "vpc" {
  name = "main-vpc"
}

data "google_compute_subnetwork" "subnet" {
  name   = "main-subnet"
  region = var.region
}

# Use official Talos GCP image
data "google_compute_image" "talos" {
  project = "talos-cloud"
  family  = "talos-1-11"
}

resource "google_compute_instance" "node" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.talos.self_link
      size  = var.disk_size_gb
      type  = var.disk_type
    }
  }

  network_interface {
    subnetwork = data.google_compute_subnetwork.subnet.self_link

    # Assign external IP for cluster communication
    access_config {
      # Ephemeral external IP
    }
  }

  # Inject Talos machine configuration via metadata
  metadata = {
    user-data = var.talos_config
  }

  # Allow Talos to modify instance metadata
  service_account {
    scopes = ["cloud-platform"]
  }

  # Tags for firewall rules
  tags = ["talos-node", var.role]

  labels = {
    role         = var.role
    managed-by   = "stolos"
    architecture = var.architecture
  }

  # Prevent accidental deletion
  lifecycle {
    ignore_changes = [
      metadata["user-data"],  # Config applied once at creation
    ]
  }
}
