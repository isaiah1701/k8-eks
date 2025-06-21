module "cert_manager_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "cert-manager" ## cert manager role 
  attach_cert_manager_policy = true

  cert_manager_hosted_zone_arns = ["arn:aws:route53:::hostedzone/Z03994962AFOWF5PYD3N9"] # Replace with your actual hosted zone ARN
   ## only gives my hosted zone access to cert manager
  oidc_providers = {
    ex =  {                                                                
      provider_arn               = module.eks.oidc_provider_arn 
      ## OIDC provider is used to allow the IAM role to be assumed by the Kubernetes service account
      namespace_service_accounts = ["cert-manager:cert-manager"]
    }
  }


  tags = local.tags  ## standardising tags for all resources
}





module "external_dns_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "external-dns" # role name for external DNS
  attach_external_dns_policy = true 

  external_dns_hosted_zone_arns = ["arn:aws:route53:::hostedzone/eu-west-2"] #gives access to hosted zones 

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn 
      namespace_service_accounts = ["external-dns:external-dns"]
      ##only allows external-dns service account in the external-dns namespace to assume this role
    }
  }

  tags = local.tags  ## standardising tags for all resources
}
