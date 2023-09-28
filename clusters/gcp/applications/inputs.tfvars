gcp_region       = "europe-west1"
gcp_location     = "europe-west1"
gcp_project      = "galaxy-platform"

cluster_name                  = "applications"

ign_replicas                  = 2
ign_hpa_minReplicas           = 8
ign_hpa_maxReplicas           = 15
ign_hpa_target_cpu            = 70
ign_hpa_target_mem            = 70
ign_min_available             = 4
ign_request_memory            = "2Gi"
ign_request_cpu               = "500m"
ign_run_cloudflare_ips_check  = true
ign_allow_only_cloudflare     = true
ign_log_flush                 = "1m"

prom_host           = "prometheus.galaxy.ma"
prom_request_cpu    = "500m"
prom_request_memory = "3Gi"
prom_limit_cpu      = "500m"
prom_limit_memory   = "3Gi"

memc_request_memory            = "2000Mi"
memc_cache_size                = "2000"
memc_request_cpu               = "500m"
memc_svc_clusertip             = "172.0.185.8"

traefik_svc_clusertip                  = "172.0.128.111"
