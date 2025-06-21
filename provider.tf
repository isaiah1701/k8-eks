terraform {
  required_version = ">= 1.0"  # Minimum Terraform version needed

  # Define which cloud providers this project uses
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # AWS provider for creating infrastructure
    }
    kubernetes = {
      source  = "hashicorp/kubernetes" 
      version = "~> 2.23"  # Kubernetes provider for cluster resources
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"  # Helm provider for application deployments
    }
  }
  
  # Remote state storage in S3 with DynamoDB locking
  backend "s3" {
    bucket         = "terraform-state-isaiah-k8s-lab"      # S3 bucket for state file
    key            = "eks-cluster/terraform.tfstate"       # State file path
    region         = "eu-west-2"                           # AWS region
    dynamodb_table = "terraform-state-lock-k8s-lab"       # Prevents concurrent runs
    encrypt        = true                                  # Encrypts state file
  }
}

# AWS PROVIDER - Configures connection to AWS services
provider "aws" {
  region = var.region  # AWS region from variables
  
  # Tags applied to all AWS resources automatically
  default_tags {
    tags = {
      Environment = var.environment     # Environment (dev/staging/prod)
      Project     = "k8s-advanced-lab"  # Project identifier
      ManagedBy   = "terraform"         # Shows Terraform manages this
      Owner       = "Isaiah"            # Resource owner
    }
  }
}

# KUBERNETES PROVIDER - Configures connection to EKS cluster
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint          # EKS API server URL
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)  # Cluster certificate
  
  # Uses AWS CLI to get authentication tokens
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks", "get-token",
      "--cluster-name", module.eks.cluster_name,
      "--region", var.region
    ]
  }
}

# HELM PROVIDER - Configures Helm for application installations
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint          # Same EKS connection
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    
    # Uses AWS CLI for authentication
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks", "get-token", 
        "--cluster-name", module.eks.cluster_name,
        "--region", var.region
      ]
    }
  }
}