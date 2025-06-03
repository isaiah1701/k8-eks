terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket  = "eks-s3-terraform-isaiah" # ✅ Replace with your actual S3 bucket name
    key     = "eks-lab"
    region  = "eu-west-2" # ✅ Replace with your actual region
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2" # ✅ Make sure this matches your backend region
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}


provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)


    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }




}

# ✅ Set to true if you want to skip TLS verification
