

resource "kubernetes_namespace" "aws_load_balancer_controller" {
  metadata {
    labels = {
      app = "demo-app"
    }
    name = "aws-load-balancer-controller"
  }
}

resource "kubernetes_namespace" "application" {
  metadata {
    labels = {
      app = "demo-app"
    }
    name = "application"
  }
}