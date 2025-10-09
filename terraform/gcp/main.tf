terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
  backend "gcs" {
    bucket = "stolos-tf-state-58wduim4"
    prefix = "infrastructure/state"
  }
}

provider "google" {
  project = "cedille-464122"
  region  = "us-central1"
}

# VPC Network
resource "google_compute_network" "main_vpc" {
  name                    = "main-vpc"
  auto_create_subnetworks = false
}

# Subnet for VM instances
resource "google_compute_subnetwork" "main_subnet" {
  name          = "main-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.main_vpc.id
}

# Output values for VM provisioning
output "network_name" {
  value = google_compute_network.main_vpc.name
}

output "subnet_name" {
  value = google_compute_subnetwork.main_subnet.name
}