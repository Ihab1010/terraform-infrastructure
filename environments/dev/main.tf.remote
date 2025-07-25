# =============================================================================
# DEV ENVIRONMENT - MAIN CONFIGURATION
# =============================================================================

terraform {
  required_version = ">= 1.0"
  
  # Remote state configuration
  backend "gcs" {
    bucket = "terraform-state-gcp-nginx-lb"
    prefix = "environments/dev"
  }
  
  required_providers {
    google = {
      source  = "registry.opentofu.org/hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  project_id           = var.project_id
  region               = var.region
  network_name         = var.network_name
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidr  = var.private_subnet_cidr
  proxy_subnet_cidr    = var.proxy_subnet_cidr
}

# Load Balancer Module
module "load_balancer" {
  source = "../../modules/load-balancer"

  project_id                = var.project_id
  region                    = var.region
  vpc_id                    = module.networking.vpc_id
  private_subnet_id         = module.networking.private_subnet_id
  nginx_instance_group_id   = module.compute.nginx_instance_group_id
  core_instance_group_id    = module.compute.core_instance_group_id
  health_check_interval     = var.health_check_interval
  health_check_timeout      = var.health_check_timeout
  health_check_healthy_threshold   = var.health_check_healthy_threshold
  health_check_unhealthy_threshold = var.health_check_unhealthy_threshold
  session_affinity          = var.session_affinity
  backend_timeout_sec       = var.backend_timeout_sec
}

# Compute Module
module "compute" {
  source = "../../modules/compute"

  project_id           = var.project_id
  zone                 = var.zone
  public_subnet_id     = module.networking.public_subnet_id
  private_subnet_id    = module.networking.private_subnet_id
  nginx_health_check_id = module.load_balancer.nginx_health_check_id
  core_health_check_id  = module.load_balancer.core_health_check_id
  
  # NGINX Configuration
  nginx_machine_type   = var.nginx_machine_type
  nginx_source_image   = var.nginx_source_image
  nginx_disk_size_gb   = var.nginx_disk_size_gb
  nginx_instance_count = var.nginx_instance_count
  nginx_startup_script = var.nginx_startup_script
  
  # Core Configuration
  core_machine_type    = var.core_machine_type
  core_source_image    = var.core_source_image
  core_disk_size_gb    = var.core_disk_size_gb
  core_instance_count  = var.core_instance_count
  core_startup_script  = var.core_startup_script
}

# DNS Module
module "dns" {
  source = "../../modules/dns"

  project_id              = var.project_id
  vpc_id                  = module.networking.vpc_id
  dns_zone_name           = var.dns_zone_name
  dns_zone_dns_name       = var.dns_zone_dns_name
  dns_record_ttl          = var.dns_record_ttl
  core_load_balancer_ip   = module.load_balancer.core_forwarding_rule_ip
  nginx_load_balancer_ip  = module.load_balancer.nginx_forwarding_rule_ip
  create_nginx_dns_record = var.create_nginx_dns_record
  create_core_instances_dns_record = var.create_core_instances_dns_record
  core_instances_ips      = var.core_instances_ips
} 