# =============================================================================
# DEV ENVIRONMENT - TERRAFORM.TFVARS EXAMPLE
# =============================================================================
# Copy this file to terraform.tfvars and update the values as needed

# GCP Configuration
project_id = "your-dev-project-id"
region     = "us-central1"
zone       = "us-central1-a"

# Network Configuration
network_name        = "nginx-vpc-dev"
public_subnet_cidr  = "10.0.0.0/24"
private_subnet_cidr = "10.0.1.0/24"
proxy_subnet_cidr   = "10.0.2.0/24"

# NGINX Instance Configuration - Dev optimized
nginx_machine_type   = "e2-micro"
nginx_source_image   = "projects/debian-cloud/global/images/family/debian-11"
nginx_disk_size_gb   = 10
nginx_instance_count = 2

# Core Instance Configuration - Dev optimized
core_machine_type   = "e2-micro"
core_source_image   = "projects/debian-cloud/global/images/family/debian-11"
core_disk_size_gb   = 10
core_instance_count = 2

# Load Balancer Configuration
health_check_interval           = 5
health_check_timeout           = 5
health_check_healthy_threshold = 2
health_check_unhealthy_threshold = 2
session_affinity               = "NONE"
backend_timeout_sec            = 30

# DNS Configuration
dns_zone_name = "test-internal-zone-dev"
dns_zone_dns_name = "test.internal."
dns_record_ttl = 300
create_nginx_dns_record = false
create_core_instances_dns_record = false
core_instances_ips = [] 