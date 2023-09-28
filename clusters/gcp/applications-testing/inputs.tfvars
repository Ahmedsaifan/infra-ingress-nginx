gcp_region       = "europe-west1"
gcp_location     = "europe-west1-b"
gcp_project      = "galaxy-platform-pre"

cluster_name                  = "applications-testing"

ign_replicas                  = 1
ign_hpa_minReplicas           = 1
ign_hpa_maxReplicas           = 2
ign_hpa_target_cpu            = 80
ign_hpa_target_mem            = 80
ign_min_available             = 1
ign_request_memory            = "600Mi"
ign_request_cpu               = "250m"
ign_allow_only_cloudflare     = true
ign_log_flush                 = "1s"


prom_host           = "prometheus-pre.galaxy.ma"
prom_request_cpu    = "100m"
prom_request_memory = "1.5Gi"
prom_limit_cpu      = "100m"
prom_limit_memory   = "1.5Gi"


memc_request_memory            = "1000Mi"
memc_cache_size                = "1000"
memc_request_cpu               = "100m"
memc_svc_clusertip             = "172.0.71.19"

traefik_svc_clusertip                  = "172.0.64.111"