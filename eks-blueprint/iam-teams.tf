# platform team that manages the EKS cluster provisioning. 

data "aws_caller_identity" "current" {
}

module "eks_blueprints_platform_teams" {
  source  = "aws-ia/eks-blueprints-teams/aws"
  version = "~> 0.2"

  name = "team-platform"

  # Enables elevated, admin privileges for this team. This impies team-platform will be ADMIN of the EKS cluster
  enable_admin = true

  # Define who can impersonate the team-platform Role
  # The module will create a new IAM Role and we define on line 18 which other entities (user or roles) 
  # will be able to impersonate this role and be able to gain Admin access on the cluster.
  users             = [data.aws_caller_identity.current.arn, "arn:aws:iam::750468095743:user/test-user", "arn:aws:iam::389029577690:user/test-user"]
  cluster_arn       = module.eks_cluster.cluster_arn
  oidc_provider_arn = module.eks_cluster.oidc_provider_arn

  labels = {
    "team" = "platform"

  }

  annotations = {
    team = "platform"
  }
  # The platform team needs to own a dedicated Kubernetes namespace so that they can deploy 
  # some cluster level Kubernetes objects, like Network policies, Security control manifest, Autoscaling configuration etc...
  # KES blueprint will create a namespace called team-platform
  namespaces = {
    "team-platform" = {

      resource_quota = {
        hard = {
          "requests.cpu"    = "10000m",
          "requests.memory" = "20Gi",
          "limits.cpu"      = "20000m",
          "limits.memory"   = "50Gi",
          "pods"            = "20",
          "secrets"         = "20",
          "services"        = "20"
        }
      }

      limit_range = {
        limit = [
          {
            type = "Pod"
            max = {
              cpu    = "1000m"
              memory = "1Gi"
            },
            min = {
              cpu    = "10m"
              memory = "4Mi"
            }
          },
          {
            type = "PersistentVolumeClaim"
            min = {
              storage = "24M"
            }
          }
        ]
      }
    }

  }

  tags = {
    Environment = "sandbox"
    Terraform   = "true"
    Team        = "platform"
  }
}



# Add additional Application Teams to our cluster
# We can create every team in a separate module, as we did with the platform-team above, 
# or we can declare multiple teams in one module using the for_each syntax

# module "eks_blueprints_app_teams" {
#   source  = "aws-ia/eks-blueprints-teams/aws"
#   version = "~> 0.2"

#   for_each = {
#     burnham = {
#       labels = {
#         Team = "burnam"
#       }
#     }
#     riker = {
#       labels = {
#         Team = "riker"
#       }
#     }
#   }
#   name = "team-${each.key}"

#   users             = [] # replace with user ARN's or role ARN's
#   cluster_arn       = module.eks_cluster.cluster_arn
#   oidc_provider_arn = module.eks_cluster.oidc_provider_arn

#   labels = merge(
#     {
#       team = each.key
#     },
#     try(each.value.labels, {})
#   )

#   annotations = {
#     team = each.key
#   }

#   namespaces = {
#     "team-${each.key}" = {
#       labels = merge(
#         {
#           team = each.key
#         },
#         try(each.value.labels, {})
#       )

#       resource_quota = {
#         hard = {
#           "requests.cpu"    = "100",
#           "requests.memory" = "20Gi",
#           "limits.cpu"      = "200",
#           "limits.memory"   = "50Gi",
#           "pods"            = "15",
#           "secrets"         = "10",
#           "services"        = "20"
#         }
#       }

#       limit_range = {
#         limit = [
#           {
#             type = "Pod"
#             max = {
#               cpu    = "2"
#               memory = "1Gi"
#             }
#             min = {
#               cpu    = "10m"
#               memory = "4Mi"
#             }
#           },
#           {
#             type = "PersistentVolumeClaim"
#             min = {
#               storage = "24M"
#             }
#           },
#           {
#             type = "Container"
#             default = {
#               cpu    = "50m"
#               memory = "24Mi"
#             }
#           }
#         ]
#       }
#     }
#   }

#   tags = {
#     Environment = "sandbox"
#     Terraform   = "true"
#     Team        = "application"
#   }

# }