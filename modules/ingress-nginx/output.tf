output "lb_ip" {
  description = "Cloud Load Balancer pointing to K8S Ingress"
  value       = data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress.0.hostname
}

output "namespace" {
  value       = kubernetes_namespace.ingress_nginx.metadata[0].name
}
