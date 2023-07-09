# We need to declare aws terraform provider. You may want to update the aws region

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "k8s-project-bucket-2023"
    key            = "jjtech/terraform.tfstate"
    region         = "us-east-1"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "jjtech-dynamodb"
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Name    = "k8s_immersion_batch"
      project = "eks_demo"
    }
  }
}


data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.cluster.id
}

data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.cluster.id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
  # load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
    # load_config_file       = false
  }
}