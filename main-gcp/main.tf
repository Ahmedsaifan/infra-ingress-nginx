locals {
  github_repo = "infrastructure-mrissa-ingress-nginx"
  shared_k8s_tags = merge({
    managed-by        = "terraform"
  }, {
    github-repo = local.github_repo
  }) 
}

module "ingress-nginx" {
  source = "../modules/ingress-nginx"

  platform                              = "gcp"
  cluster_name                          = var.cluster_name
  github_repo                           = local.github_repo
  shared_k8s_tags                       = local.shared_k8s_tags

  ign_helm_version                      = var.ign_helm_version
  ign_replicas                          = var.ign_replicas
  ign_hpa_minReplicas                   = var.ign_hpa_minReplicas
  ign_hpa_maxReplicas                   = var.ign_hpa_maxReplicas
  ign_hpa_target_cpu                    = var.ign_hpa_target_cpu
  ign_hpa_target_mem                    = var.ign_hpa_target_mem
  ign_min_available                     = var.ign_min_available
  ign_request_memory                    = var.ign_request_memory
  ign_request_cpu                       = var.ign_request_cpu
  ign_limit_memory                      = var.ign_limit_memory
  ign_limit_cpu                         = var.ign_limit_cpu
  ign_use_service_upstream              = var.ign_use_service_upstream
  ign_external_traffic_policy           = var.ign_external_traffic_policy
  ign_allow_only_cloudflare             = var.ign_allow_only_cloudflare
  ign_run_cloudflare_ips_check          = var.ign_run_cloudflare_ips_check
  ign_log_flush                         = var.ign_log_flush
  ign_lb_ip                             = google_compute_address.ip_address.address
  

  prom_host                             = var.prom_host
  prom_request_cpu                      = var.prom_request_cpu
  prom_request_memory                   = var.prom_request_memory
  prom_limit_cpu                        = var.prom_limit_cpu
  prom_limit_memory                     = var.prom_limit_memory

  letsencrypt_issuer                    = var.letsencrypt_issuer

  memc_svc_clusertip                    = var.memc_svc_clusertip

  traefik_svc_clusertip                 = var.traefik_svc_clusertip
}


module "memcached" {
  source = "../modules/memcached"

  cluster_name                          = var.cluster_name
  github_repo                           = local.github_repo
  shared_k8s_tags                       = local.shared_k8s_tags

  ign_namespace                         = module.ingress-nginx.namespace
  memc_request_memory                   = var.memc_request_memory
  memc_cache_size                       = var.memc_cache_size
  memc_request_cpu                      = var.memc_request_cpu
  memc_svc_clusertip                    = var.memc_svc_clusertip
}

resource "google_compute_address" "ip_address" {
  name = "ingress-nginx-lb-ip"
  address_type = "EXTERNAL"
  network_tier = "STANDARD"
}
