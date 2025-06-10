module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = "1.29"

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  subnet_ids               = module.vpc.private_subnets
  vpc_id                   = module.vpc.vpc_id
  control_plane_subnet_ids = module.vpc.public_subnets

  tags = local.tags

  enable_irsa = true

  eks_managed_node_group_defaults = {
    disk_size      = 50
    instance_types = ["t3a.large", "t3.large"]
  }

  eks_managed_node_groups = {
    default = {}
  }

  access_entries = {
    admin = {
      principal_arn     = var.iam_user_arn
      username          = var.iam_user_name
      kubernetes_groups = ["admin"] # 👈 This is the important bit
    }
  }


}
