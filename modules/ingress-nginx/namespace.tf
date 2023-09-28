resource "kubernetes_namespace" "ingress_nginx" {
  
  metadata {
    name   = "ingress-nginx"
    labels = merge(var.shared_k8s_tags, {
      "app.kubernetes.io/instance"    = "ingress-nginx", 
      "app.kubernetes.io/name"        = "ingress-nginx" 
      "mrissa.galaxykube.com/pull-ecr" = "yes"
    })
    annotations = {
      "downscaler/exclude"      = "true"
    }
  }
}