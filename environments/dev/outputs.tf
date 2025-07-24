# =============================================================================
# DEV ENVIRONMENT OUTPUTS
# =============================================================================

# Network Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = module.networking.vpc_name
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = module.networking.public_subnet_id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = module.networking.private_subnet_id
}

# Load Balancer Outputs
output "nginx_load_balancer_ip" {
  description = "The external IP address of the NGINX load balancer"
  value       = module.load_balancer.nginx_forwarding_rule_ip
}

output "nginx_load_balancer_url" {
  description = "The URL of the NGINX load balancer"
  value       = module.load_balancer.nginx_load_balancer_url
}

output "core_load_balancer_ip" {
  description = "The internal IP address of the core load balancer"
  value       = module.load_balancer.core_forwarding_rule_ip
}

output "core_load_balancer_url" {
  description = "The internal URL of the core load balancer"
  value       = module.load_balancer.core_load_balancer_url
}

# Compute Outputs
output "nginx_instance_group_id" {
  description = "The ID of the NGINX instance group"
  value       = module.compute.nginx_instance_group_id
}

output "core_instance_group_id" {
  description = "The ID of the core instance group"
  value       = module.compute.core_instance_group_id
}

# DNS Outputs
output "dns_zone_id" {
  description = "The ID of the private DNS zone"
  value       = module.dns.dns_zone_id
}

output "core_lb_dns_name" {
  description = "The DNS name for the core load balancer"
  value       = module.dns.core_lb_dns_name
}

# AWX/Ansible Integration Outputs
output "awx_inventory" {
  description = "Inventory data for AWX/Ansible"
  value = {
    nginx_servers = {
      load_balancer_ip = module.load_balancer.nginx_forwarding_rule_ip
      load_balancer_url = module.load_balancer.nginx_load_balancer_url
      instance_group_id = module.compute.nginx_instance_group_id
      environment = "dev"
    }
    core_servers = {
      load_balancer_ip = module.load_balancer.core_forwarding_rule_ip
      load_balancer_url = module.load_balancer.core_load_balancer_url
      instance_group_id = module.compute.core_instance_group_id
      environment = "dev"
    }
    infrastructure = {
      vpc_id = module.networking.vpc_id
      vpc_name = module.networking.vpc_name
      public_subnet_id = module.networking.public_subnet_id
      private_subnet_id = module.networking.private_subnet_id
      dns_zone_id = module.dns.dns_zone_id
      region = var.region
      zone = var.zone
    }
  }
}

# Summary Outputs
output "infrastructure_summary" {
  description = "Summary of the deployed infrastructure"
  value = {
    vpc_name                    = module.networking.vpc_name
    nginx_load_balancer_url     = module.load_balancer.nginx_load_balancer_url
    core_load_balancer_url      = module.load_balancer.core_load_balancer_url
    nginx_instance_count        = var.nginx_instance_count
    core_instance_count         = var.core_instance_count
    dns_zone_name              = module.dns.dns_zone_name
    region                     = var.region
    zone                       = var.zone
  }
} 