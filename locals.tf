locals {

  name   = "eks-cluster"   ## local variables 
  region = "eu-west-2"


  tags = {
    project       = "eks lab"
    "Environment" = "sandbox"
    "Owner"       = "Isaiah Michael"
  }
}