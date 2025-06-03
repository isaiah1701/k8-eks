module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = "1.29"

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  # Add these based on your setup
  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  control_plane_subnet_ids = module.vpc.public_subnets

  # Tags for the EKS cluster
  tags = local.tags


  # Enable IAM roles for service accounts (IRSA)


  enable_irsa = true


  eks_managed_node_group_defaults = {

    disk_size = 50 # Adjust disk size as needed


    instance_types = ["t3a.large", "t3.large"] # Add more instance types as needed

  }


  eks_managed_node_groups = {
    default = {}
  }



  # Optional: Enable Kubernetes dashboard


}
