project_config = {
    "cluster_name": "eks-lab",
    "region": "eu-west-2",
    "helm_owner": "isaiah4748",
    "iam_user": "isaiah4748",
    "account_id": "282378667097",
    "terraform_backend": {
        "bucket": "eks-s3-terraform-isaiah",
        "key": "eks-cluster",
        "region": "eu-west-2"
    }
}

components = {
    "infrastructure": {
        "eks_cluster": {
            "name": "EKS Cluster",
            "description": "Amazon EKS cluster running version 1.28",
            "features": [
                "Managed node groups for worker nodes",
                "IRSA enabled",
                "KMS encryption for secrets",
                "VPC with public/private subnets"
            ]
        }
    },
    "applications": {
        "nginx_ingress": {
            "name": "NGINX Ingress Controller",
            "namespace": "ingress-nginx",
            "chart": "ingress-nginx",
            "repository": "https://kubernetes.github.io/ingress-nginx",
            "purpose": "Routes external traffic to services"
        },
        "cert_manager": {
            "name": "Cert Manager",
            "namespace": "cert-manager",
            "chart": "cert-manager",
            "repository": "https://charts.jetstack.io",
            "version": "v1.14.4",
            "purpose": "Automatic SSL/TLS certificate management",
            "features": ["Let's Encrypt integration", "Route53 DNS validation"]
        },
        "external_dns": {
            "name": "External DNS",
            "namespace": "external-dns",
            "chart": "external-dns",
            "repository": "https://charts.bitnami.com/bitnami",
            "version": "6.28.3",
            "purpose": "Manages Route53 DNS records automatically"
        },
        "argocd": {
            "name": "ArgoCD",
            "namespace": "argo-cd",
            "chart": "argo-cd",
            "version": "8.0.16",
            "purpose": "GitOps continuous delivery tool"
        }
    },
    "security": {
        "irsa_roles": {
            "cert_manager": "Manages Route53 records for DNS validation",
            "external_dns": "Creates/updates Route53 records"
        }
    }
}

deployment_steps = [
    {
        "step": 1,
        "title": "Setup S3 Backend",
        "description": "Create S3 bucket for Terraform state",
        "commands": [
            "aws s3 mb s3://eks-s3-terraform-isaiah --region eu-west-2"
        ]
    },
    {
        "step": 2,
        "title": "Initialize Terraform",
        "description": "Initialize and validate configuration",
        "commands": [
            "terraform init",
            "terraform validate",
            "terraform plan"
        ]
    },
    {
        "step": 3,
        "title": "Deploy EKS",
        "description": "Create the EKS cluster",
        "commands": [
            "terraform apply -target=module.eks",
            "aws eks update-kubeconfig --region eu-west-2 --name eks-lab"
        ]
    },
    {
        "step": 4,
        "title": "Deploy Applications",
        "description": "Install Helm applications",
        "commands": [
            "terraform apply"
        ]
    }
]

architecture_components = {
    "control_plane": "AWS managed EKS control plane",
    "worker_nodes": "EC2 instances in managed node groups",
    "networking": "VPC with public/private subnets",
    "security": "IAM roles and security groups"
}