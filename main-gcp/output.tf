output "lb_ip" {
  description = "Cloud Load Balancer pointing to K8S Ingress"
  value       = module.ingress-nginx.lb_ip
}