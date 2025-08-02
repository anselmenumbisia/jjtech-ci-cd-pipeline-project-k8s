module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.2.0"

  name = "eks-blueprint-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


# # Get datasource for VPC
# data "aws_vpc" "vpc" {
#   filter {
#     name   = "tag:Name"
#     values = ["Sandbox-Template"]
#   }

#   # Add more filters if needed
# }

# data "aws_subnets" "public_subnets" {
#   filter {
#     name   = "tag:Name"
#     values = ["Network-SandboxNat-A", "Network-SandboxNat-B"]
#   }

# }

# data "aws_subnets" "private_subnets" {
#   filter {
#     name   = "tag:Name"
#     values = ["Network-Sandbox-A", "Network-Sandbox-B"]
#   }

# }


# # resource "aws_subnet" "tagged_public_subnets" {
# #   for_each = toset(data.aws_subnets.public_subnets.ids)

# #   vpc_id = data.aws_vpcs.vpcs.id

# #   tags = {
# #     "kubernetes.io/role/elb"           = "1"
# #     "kubernetes.io/cluster/${var.cluster_name}" = "owned"
# #   }
# # }

# # resource "aws_subnet" "tagged_private_subnets" {
# #   for_each = toset(data.aws_subnets.private_subnets.ids)

# #   vpc_id = data.aws_vpcs.vpcs.id

# #   tags = {
# #     "kubernetes.io/role/internal-elb"           = "1"
# #     "kubernetes.io/cluster/${var.cluster_name}" = "owned"
# #   }
# # }
