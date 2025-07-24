# =============================================================================
# COMPUTE MODULE OUTPUTS
# =============================================================================

output "nginx_instance_group_id" {
  description = "The ID of the NGINX instance group"
  value       = google_compute_instance_group_manager.nginx_group.instance_group
}

output "nginx_instance_group_name" {
  description = "The name of the NGINX instance group"
  value       = google_compute_instance_group_manager.nginx_group.name
}

output "nginx_instance_group_self_link" {
  description = "The self-link of the NGINX instance group"
  value       = google_compute_instance_group_manager.nginx_group.instance_group
}

output "core_instance_group_id" {
  description = "The ID of the core instance group"
  value       = google_compute_instance_group_manager.core_group.instance_group
}

output "core_instance_group_name" {
  description = "The name of the core instance group"
  value       = google_compute_instance_group_manager.core_group.name
}

output "core_instance_group_self_link" {
  description = "The self-link of the core instance group"
  value       = google_compute_instance_group_manager.core_group.instance_group
}

output "nginx_template_id" {
  description = "The ID of the NGINX instance template"
  value       = google_compute_instance_template.nginx_template.id
}

output "core_template_id" {
  description = "The ID of the core instance template"
  value       = google_compute_instance_template.core_template.id
} 