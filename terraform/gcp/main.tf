terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
  backend "gcs" {
    bucket = "stolos-tf-state-ofabtxq5"
    prefix = "infrastructure/state"
  }
}

provider "google" {
  project = "cedille-464122"
  region  = "us-central1"
}

# VPC Network
resource "google_compute_network" "main_vpc" {
  name                    = "stolos-cluster-vpc"
  auto_create_subnetworks = false
}

# Subnet for VM instances
# - On-prem pods: 10.244.0.0/16
# - On-prem services: 10.96.0.0/12
resource "google_compute_subnetwork" "main_subnet" {
  name          = "stolos-cluster-subnet"
  ip_cidr_range = "172.16.0.0/20"
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