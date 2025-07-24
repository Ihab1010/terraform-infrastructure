# =============================================================================
# DNS MODULE OUTPUTS
# =============================================================================

output "dns_zone_id" {
  description = "The ID of the private DNS zone"
  value       = google_dns_managed_zone.private_zone.id
}

output "dns_zone_name" {
  description = "The name of the private DNS zone"
  value       = google_dns_managed_zone.private_zone.name
}

output "dns_zone_dns_name" {
  description = "The DNS name of the private zone"
  value       = google_dns_managed_zone.private_zone.dns_name
}

output "core_lb_dns_name" {
  description = "The DNS name for the core load balancer"
  value       = "core.${var.dns_zone_dns_name}"
}

output "nginx_lb_dns_name" {
  description = "The DNS name for the NGINX load balancer"
  value       = var.create_nginx_dns_record ? "nginx.${var.dns_zone_dns_name}" : ""
} 