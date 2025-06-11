module "cert_manager_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "cert-manager" # Use 'role_name' instead

  attach_cert_manager_policy = true

  cert_manager_hosted_zone_arns = ["arn:aws:route53:::hostedzone/Z03994962AFOWF5PYD3N9"] # Replace with your actual hosted zone ARN

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["cert-manager:cert-manager"]
    }
  }


  tags = local.tags
}


## External DNS IRSA Role


module "external_dns_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "external-dns" # Use 'role_name' instead

  attach_external_dns_policy = true

  external_dns_hosted_zone_arns = ["arn:aws:route53:::hostedzone/eu-west-2"] # Replace with your actual hosted zone ARN

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-dns:external-dns"]
    }
  }

  tags = local.tags
}
