module "eks" {
  source  = "terraform-aws-modules/eks/aws" ##pulls eks module from terraform registry
  version = "~> 20.0"

  cluster_name    = local.name ## cluster name defined in localls and k8 recent stable version 
  cluster_version = "1.29"

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"] ## enables public access to cluster 

  subnet_ids               = module.vpc.private_subnets ##attach to vpc and subnets 
  vpc_id                   = module.vpc.vpc_id
  control_plane_subnet_ids = module.vpc.public_subnets ## keeps control plane in public subnets for access

  tags = local.tags  ## stanadardising tags for all resources

  enable_irsa = true ## allows IAM roles for service accounts ensuring least privilege access

  eks_managed_node_group_defaults = {  ## default settings for EKS managed node groups
    disk_size      = 50  ## 50 GB disk size for each node
    instance_types = ["t3a.large", "t3.large"]
  }

  eks_managed_node_groups = {
    default = {}  ## uses default node group settings defined above
  }

  access_entries = {
    admin = {
      principal_arn     = var.iam_user_arn  ## maps iam user to k8 admin role 
      username          = var.iam_user_name 
      kubernetes_groups = ["admin"] 
    }
  }


}
