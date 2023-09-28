module "ingress-nginx" {
  source = "../modules/ingress-nginx"

  platform                              = "aws"
  cluster_name                          = var.cluster_name

  ign_helm_version                      = var.ign_helm_version
  ign_replicas                          = var.ign_replicas
  ign_hpa_minReplicas                   = var.ign_hpa_minReplicas
  ign_hpa_maxReplicas                   = var.ign_hpa_maxReplicas
  ign_request_memory                    = var.ign_request_memory
  ign_request_cpu                       = var.ign_request_cpu
  ign_limit_memory                      = var.ign_limit_memory
  ign_limit_cpu                         = var.ign_limit_cpu
  ign_use_service_upstream              = var.ign_use_service_upstream
  prom_request_cpu                      = var.prom_request_cpu
  prom_request_memory                   = var.prom_request_memory
  prom_limit_cpu                        = var.prom_limit_cpu
  prom_limit_memory                     = var.prom_limit_memory


}


output "lb_ip" {
  description = "Cloud Load Balancer pointing to K8S Ingress"
  value       = module.ingress-nginx.lb_ip
}