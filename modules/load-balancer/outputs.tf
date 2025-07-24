# =============================================================================
# LOAD BALANCER MODULE OUTPUTS
# =============================================================================

output "nginx_health_check_id" {
  description = "The ID of the NGINX health check"
  value       = google_compute_health_check.nginx_health_check.id
}

output "core_health_check_id" {
  description = "The ID of the core health check"
  value       = google_compute_health_check.core_health_check.id
}

output "nginx_backend_service_id" {
  description = "The ID of the NGINX backend service"
  value       = google_compute_backend_service.nginx_backend.id
}

output "core_backend_service_id" {
  description = "The ID of the core backend service"
  value       = google_compute_region_backend_service.core_backend.id
}

output "nginx_forwarding_rule_ip" {
  description = "The external IP address of the NGINX load balancer"
  value       = google_compute_global_forwarding_rule.nginx_forwarding_rule.ip_address
}

output "core_forwarding_rule_ip" {
  description = "The internal IP address of the core load balancer"
  value       = google_compute_forwarding_rule.core_forwarding_rule.ip_address
}

output "nginx_load_balancer_url" {
  description = "The URL of the NGINX load balancer"
  value       = "http://${google_compute_global_forwarding_rule.nginx_forwarding_rule.ip_address}"
}

output "core_load_balancer_url" {
  description = "The internal URL of the core load balancer"
  value       = "http://${google_compute_forwarding_rule.core_forwarding_rule.ip_address}"
} 