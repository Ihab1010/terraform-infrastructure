# =============================================================================
# NETWORKING MODULE - VPC, SUBNETS, AND FIREWALL RULES
# =============================================================================

# VPC Network
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

# Public Subnet for Load Balancer and Public Instances
resource "google_compute_subnetwork" "public_subnet" {
  name          = "${var.network_name}-public"
  ip_cidr_range = var.public_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  project       = var.project_id
}

# Private Subnet for Internal Services
resource "google_compute_subnetwork" "private_subnet" {
  name          = "${var.network_name}-private"
  ip_cidr_range = var.private_subnet_cidr
  network       = google_compute_network.vpc.id
  region        = var.region
  private_ip_google_access = true
  project       = var.project_id
}

# Proxy-only Subnetwork for Internal Load Balancer
resource "google_compute_subnetwork" "proxy_only" {
  name          = "${var.network_name}-proxy-only"
  ip_cidr_range = var.proxy_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  project       = var.project_id
}

# Firewall Rule - HTTP Access
resource "google_compute_firewall" "allow_http" {
  name    = "${var.network_name}-allow-http"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

# Firewall Rule - HTTPS Access
resource "google_compute_firewall" "allow_https" {
  name    = "${var.network_name}-allow-https"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}

# Firewall Rule - SSH via IAP
resource "google_compute_firewall" "allow_ssh_iap" {
  name    = "${var.network_name}-allow-ssh-iap"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

# Firewall Rule - Egress Traffic
resource "google_compute_firewall" "allow_egress" {
  name    = "${var.network_name}-allow-egress"
  network = google_compute_network.vpc.name
  project = var.project_id

  direction = "EGRESS"
  allow {
    protocol = "all"
  }
  destination_ranges = ["0.0.0.0/0"]
}

# Firewall Rule - Internal Communication
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = [var.public_subnet_cidr, var.private_subnet_cidr]
}

# Firewall Rule - Core Service Access
resource "google_compute_firewall" "allow_core_from_public" {
  name    = "${var.network_name}-allow-core-from-public"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_tags = ["http-server"]
  target_tags = ["core-service"]
} 