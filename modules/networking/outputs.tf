# =============================================================================
# NETWORKING MODULE OUTPUTS
# =============================================================================

output "vpc_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = google_compute_network.vpc.name
}

output "vpc_self_link" {
  description = "The self-link of the VPC"
  value       = google_compute_network.vpc.self_link
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = google_compute_subnetwork.public_subnet.id
}

output "public_subnet_name" {
  description = "The name of the public subnet"
  value       = google_compute_subnetwork.public_subnet.name
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = google_compute_subnetwork.private_subnet.id
}

output "private_subnet_name" {
  description = "The name of the private subnet"
  value       = google_compute_subnetwork.private_subnet.name
}

output "proxy_subnet_id" {
  description = "The ID of the proxy-only subnet"
  value       = google_compute_subnetwork.proxy_only.id
}

output "proxy_subnet_name" {
  description = "The name of the proxy-only subnet"
  value       = google_compute_subnetwork.proxy_only.name
} 