# =============================================================================
# COMPUTE MODULE - INSTANCE TEMPLATES AND MANAGED INSTANCE GROUPS
# =============================================================================

# Public NGINX Instance Template
resource "google_compute_instance_template" "nginx_template" {
  name_prefix  = "nginx-template-"
  machine_type = var.nginx_machine_type
  project      = var.project_id

  disk {
    source_image = var.nginx_source_image
    auto_delete  = true
    boot         = true
    disk_size_gb = var.nginx_disk_size_gb
  }

  network_interface {
    subnetwork = var.public_subnet_id
    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = var.nginx_startup_script

  tags = ["http-server", "https-server"]

  lifecycle {
    create_before_destroy = true
  }
}

# Public NGINX Managed Instance Group
resource "google_compute_instance_group_manager" "nginx_group" {
  name               = "nginx-group"
  base_instance_name = "nginx"
  zone               = var.zone
  project            = var.project_id

  version {
    instance_template = google_compute_instance_template.nginx_template.id
  }

  target_size = var.nginx_instance_count

  named_port {
    name = "http"
    port = 80
  }

  named_port {
    name = "https"
    port = 443
  }

  auto_healing_policies {
    health_check      = var.nginx_health_check_id
    initial_delay_sec = 300
  }
}

# Private Core Instance Template
resource "google_compute_instance_template" "core_template" {
  name_prefix  = "core-template-"
  machine_type = var.core_machine_type
  project      = var.project_id

  disk {
    source_image = var.core_source_image
    auto_delete  = true
    boot         = true
    disk_size_gb = var.core_disk_size_gb
  }

  network_interface {
    subnetwork = var.private_subnet_id
    // No access_config for private instances
  }

  metadata_startup_script = var.core_startup_script

  tags = ["core-service"]

  lifecycle {
    create_before_destroy = true
  }
}

# Private Core Managed Instance Group
resource "google_compute_instance_group_manager" "core_group" {
  name               = "core-group"
  base_instance_name = "core"
  zone               = var.zone
  project            = var.project_id

  version {
    instance_template = google_compute_instance_template.core_template.id
  }

  target_size = var.core_instance_count

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = var.core_health_check_id
    initial_delay_sec = 300
  }
} 