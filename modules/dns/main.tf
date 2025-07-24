# =============================================================================
# DNS MODULE - PRIVATE DNS ZONE AND RECORDS
# =============================================================================

# Private DNS Zone
resource "google_dns_managed_zone" "private_zone" {
  name        = var.dns_zone_name
  dns_name    = var.dns_zone_dns_name
  description = "Private DNS zone for internal services"
  visibility  = "private"
  project     = var.project_id

  private_visibility_config {
    networks {
      network_url = var.vpc_id
    }
  }
}

# DNS Record for Core Load Balancer
resource "google_dns_record_set" "core_lb_record" {
  name         = "core.${var.dns_zone_dns_name}"
  managed_zone = google_dns_managed_zone.private_zone.name
  type         = "A"
  ttl          = var.dns_record_ttl
  rrdatas      = [var.core_load_balancer_ip]
  project      = var.project_id
}

# DNS Record for NGINX Load Balancer (if needed for internal access)
resource "google_dns_record_set" "nginx_lb_record" {
  count        = var.create_nginx_dns_record ? 1 : 0
  name         = "nginx.${var.dns_zone_dns_name}"
  managed_zone = google_dns_managed_zone.private_zone.name
  type         = "A"
  ttl          = var.dns_record_ttl
  rrdatas      = [var.nginx_load_balancer_ip]
  project      = var.project_id
}

# DNS Record for Core Instances (example)
resource "google_dns_record_set" "core_instances_record" {
  count        = var.create_core_instances_dns_record ? 1 : 0
  name         = "core-instances.${var.dns_zone_dns_name}"
  managed_zone = google_dns_managed_zone.private_zone.name
  type         = "A"
  ttl          = var.dns_record_ttl
  rrdatas      = var.core_instances_ips
  project      = var.project_id
} 