# VPC MODULE - Creates isolated network environment for EKS cluster
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"  # Uses AWS VPC module from Terraform registry

  version = "5.9.0"  # Pins module version for consistency

  name = local.name  # VPC name from locals

  azs = ["${local.region}a", "${local.region}b", "${local.region}c"]  # Three availability zones for high availability

  cidr = "10.0.0.0/16"  # VPC IP address range (65,536 addresses)

  # PRIVATE SUBNETS - For EKS worker nodes (no direct internet access)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  
  # PUBLIC SUBNETS - For load balancers and NAT gateways
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway = true  # Allows private subnets to access internet for updates

  # KUBERNETES TAGS - Required for EKS load balancer integration
  public_subnet_tags = {
    "kubernetes.io/role/cluster/${local.name}" = "shared"  # EKS cluster association
    "kubernetes.io/role/internal-elb"          = "shared"  # Internal load balancer placement
  }

  tags = local.tags  # Common resource tags
}