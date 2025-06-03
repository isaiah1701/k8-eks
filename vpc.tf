module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  version = "5.9.0"

  name = local.name

  azs = ["${local.region}a", "${local.region}b", "${local.region}c"]

  cidr = "10.0.0.0/16"


  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]


  enable_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"          = "shared"
  }

  tags = local.tags
}