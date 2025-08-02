module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.27"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  enable_irsa    = true
  create_kms_key = true

  vpc_id = module.vpc.vpc_id

  subnet_ids = module.vpc.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    blueprint = {
      node_group_name = "${var.cluster_name}-nodegroup"
      min_size        = 2
      max_size        = 5
      desired_size    = 2
      instance_types  = ["t2.medium"]
      capacity_type   = "ON_DEMAND"
    }
  }

  cluster_enabled_log_types   = ["audit", "api", "authenticator"]
  create_cloudwatch_log_group = false

  # Fargate Profile(s)
  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
        }
      ]
    }
  }

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::389029577690:role/team-platform-20231208173344295400000020"
      username = "cluster-admin"
      groups   = ["system:masters"]
    },
  ]

  tags = {
    Environment = "sandbox"
    Terraform   = "true"
  }
}



# Module for EKS blueprint addons

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = ">= 1.12.0" #ensure to update this to the latest/desired version

  cluster_name      = module.eks_cluster.cluster_name
  cluster_endpoint  = module.eks_cluster.cluster_endpoint
  cluster_version   = module.eks_cluster.cluster_version
  oidc_provider_arn = module.eks_cluster.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  # ingress
  enable_aws_load_balancer_controller = true
  enable_external_dns                 = true
  enable_ingress_nginx                = false

  # cluster autosclaing
  # enable_cluster_autoscaler = true
  enable_karpenter = true

  # cluster backup
  #enable_velero = true

  # volumes
  enable_aws_efs_csi_driver = true


  #observability
  enable_aws_for_fluentbit      = true
  enable_aws_cloudwatch_metrics = true
  enable_metrics_server         = true
  enable_fargate_fluentbit      = true

  tags = {
    Environment = "sandbox"
    Terraform   = "true"
  }
}