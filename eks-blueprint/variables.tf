
variable "cluster_name" {
  description = "The name of eks cluster."
  type        = string
  default     = "eks-blueprint"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_version" {
  description = "The Version of Kubernetes to deploy"
  type        = string
  default     = "1.25"
}

variable "public_subnets" {
  type    = list(string)
  default = ["Network-SandboxNat-A", "Network-SandboxNat-B"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["Network-Sandbox-A", "Network-Sandbox-B"]
}