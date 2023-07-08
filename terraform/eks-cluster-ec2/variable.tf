variable "cluster_name" {
  default = "jjtech-demo-cluster"
}

variable "cluster_version" {
  default = "1.25"
}

variable "region" {
  default = "us-east-1"
}

variable "ingress_ports" {
  description = "Managed node groups use this security group for control-plane-to-data-plane communication."
  default     = ["443", "8080", "80", "9090", "9443", "2049"]
}