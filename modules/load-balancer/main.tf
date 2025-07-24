# =============================================================================
# LOAD BALANCER MODULE - HEALTH CHECKS, BACKEND SERVICES, AND LOAD BALANCERS
# =============================================================================

# Health Check for NGINX Instances
resource "google_compute_health_check" "nginx_health_check" {
  name               = "nginx-health-check"
  check_interval_sec = var.health_check_interval
  timeout_sec        = var.health_check_timeout
  healthy_threshold  = var.health_check_healthy_threshold
  unhealthy_threshold = var.health_check_unhealthy_threshold
  project            = var.project_id

  http_health_check {
    port = 80
  }
}

# Health Check for Core Instances
resource "google_compute_health_check" "core_health_check" {
  name               = "core-health-check"
  check_interval_sec = var.health_check_interval
  timeout_sec        = var.health_check_timeout
  healthy_threshold  = var.health_check_healthy_threshold
  unhealthy_threshold = var.health_check_unhealthy_threshold
  project            = var.project_id

  http_health_check {
    port = 80
  }
}

# External Backend Service for NGINX
resource "google_compute_backend_service" "nginx_backend" {
  name                            = "nginx-backend"
  load_balancing_scheme           = "EXTERNAL"
  protocol                        = "HTTP"
  health_checks                   = [google_compute_health_check.nginx_health_check.id]
  project                         = var.project_id

  backend {
    group = var.nginx_instance_group_id
  }

  session_affinity = var.session_affinity
  timeout_sec      = var.backend_timeout_sec
}

# Internal Backend Service for Core
resource "google_compute_region_backend_service" "core_backend" {
  name                            = "core-backend"
  load_balancing_scheme           = "INTERNAL_MANAGED"
  protocol                        = "HTTP"
  health_checks                   = [google_compute_health_check.core_health_check.id]
  region                          = var.region
  project                         = var.project_id

  backend {
    group = var.core_instance_group_id
    balancing_mode = "UTILIZATION"
    capacity_scaler = 1.0
  }

  session_affinity = var.session_affinity
  timeout_sec      = var.backend_timeout_sec
}

# External URL Map for NGINX
resource "google_compute_url_map" "nginx_url_map" {
  name            = "nginx-url-map"
  default_service = google_compute_backend_service.nginx_backend.id
  project         = var.project_id
}

# Internal URL Map for Core
resource "google_compute_region_url_map" "core_url_map" {
  name            = "core-url-map"
  default_service = google_compute_region_backend_service.core_backend.id
  region          = var.region
  project         = var.project_id
}

# External Target HTTP Proxy
resource "google_compute_target_http_proxy" "nginx_http_proxy" {
  name   = "nginx-http-proxy"
  url_map = google_compute_url_map.nginx_url_map.id
  project = var.project_id
}

# Internal Target HTTP Proxy
resource "google_compute_region_target_http_proxy" "core_http_proxy" {
  name   = "core-http-proxy"
  url_map = google_compute_region_url_map.core_url_map.id
  region = var.region
  project = var.project_id
}

# External Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "nginx_forwarding_rule" {
  name       = "nginx-forwarding-rule"
  port_range = "80"
  target     = google_compute_target_http_proxy.nginx_http_proxy.id
  load_balancing_scheme = "EXTERNAL"
  project    = var.project_id
}

# Internal Forwarding Rule
resource "google_compute_forwarding_rule" "core_forwarding_rule" {
  name                  = "core-forwarding-rule"
  region                = var.region
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  network               = var.vpc_id
  subnetwork            = var.private_subnet_id
  target                = google_compute_region_target_http_proxy.core_http_proxy.id
  ip_protocol           = "TCP"
  project               = var.project_id
} 