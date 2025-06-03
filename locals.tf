locals {

  name   = "eks-lab"
  domain = "lab.isaiahmichael.com"
  region = "eu-west-2"


  tags = {
    project       = "eks lab"
    "Environment" = "sandbox"
    "Owner"       = "Isaiah Michael"
  }
}