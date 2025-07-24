# Terraform Infrastructure - Monorepo

## **🏗️ Infrastructure Overview**

This repository contains all Terraform infrastructure code for our GCP NGINX load balancer deployment across multiple environments.

## **📁 Repository Structure**

```
terraform-infrastructure/
├── environments/
│   ├── dev/              # Development environment
│   ├── staging/          # Staging environment
│   └── production/       # Production environment
├── modules/
│   ├── networking/       # VPC, subnets, firewall rules
│   ├── compute/          # Instance templates, instance groups
│   ├── load-balancer/    # Health checks, backend services, load balancers
│   └── dns/             # Private DNS zones and records
├── .github/workflows/    # CI/CD pipelines
└── docs/                # Documentation
```

## **🌿 Branching Strategy**

```
main (production)
├── develop (dev environment)
├── staging (staging environment)
└── feature branches
    ├── feature/new-load-balancer
    ├── feature/security-updates
    └── feature/performance-optimization
```

## **🚀 Quick Start**

### **Prerequisites**
- Terraform >= 1.5.0
- Google Cloud SDK
- GCP project with appropriate permissions

### **Development Environment**
```bash
# Clone the repository
git clone <repository-url>
cd terraform-infrastructure

# Switch to develop branch
git checkout develop

# Deploy to dev environment
cd environments/dev
terraform init
terraform plan
terraform apply
```

### **Production Environment**
```bash
# Switch to main branch
git checkout main

# Deploy to production (requires approval)
cd environments/production
terraform init
terraform plan
terraform apply
```

## **🔧 Environment Configuration**

### **Dev Environment**
- **Project**: `dev-project`
- **Region**: `us-central1`
- **Instance Type**: `e2-micro`
- **Instance Count**: 2

### **Staging Environment**
- **Project**: `staging-project`
- **Region**: `us-central1`
- **Instance Type**: `e2-small`
- **Instance Count**: 3

### **Production Environment**
- **Project**: `prod-project`
- **Region**: `us-central1`
- **Instance Type**: `e2-standard-2`
- **Instance Count**: 5

## **🔒 Security & Compliance**

- ✅ **Remote state** with GCS backend
- ✅ **State encryption** with customer-managed keys
- ✅ **Environment isolation** with separate state files
- ✅ **Security scanning** with Checkov
- ✅ **Manual approval** for production deployments

## **📋 Deployment Process**

### **Development**
1. Create feature branch from `develop`
2. Make changes to modules or dev environment
3. Push to feature branch
4. Create PR to `develop`
5. CI/CD automatically deploys to dev environment

### **Staging**
1. Create PR from `develop` to `staging`
2. Review and approve changes
3. CI/CD deploys to staging environment
4. Run integration tests

### **Production**
1. Create PR from `staging` to `main`
2. Security scan and code review
3. Manual approval required
4. CI/CD deploys to production environment

## **🔄 Rollback Procedures**

### **Emergency Rollback**
```bash
# Rollback to previous state
terraform state pull > current.tfstate
terraform state push previous.tfstate
terraform apply
```

### **Code Rollback**
```bash
# Revert to previous commit
git revert HEAD
git push origin main
```

## **📞 Support**

- **Infrastructure Team**: infrastructure@company.com
- **DevOps Team**: devops@company.com
- **Emergency Contact**: oncall@company.com

## **📚 Documentation**

- [Architecture Overview](docs/architecture.md)
- [Deployment Guide](docs/deployment-guide.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Security Guidelines](docs/security.md) 