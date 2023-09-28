aws_region                    = "eu-west-1"
cluster_name                  = "applications-testing"
aws_role_arn                  = "arn:aws:iam::219868318717:role/eks-applications-testing-full-admin"

ign_replicas                  = 2
ign_hpa_minReplicas           = 2
ign_hpa_maxReplicas           = 3
ign_request_memory            = "1Gi"
ign_request_cpu               = "1.5"
ign_use_service_upstream      = true

prom_request_cpu    = "100m"
prom_request_memory = "1.5Gi"
prom_limit_cpu      = "100m"
prom_limit_memory   = "1.5Gi"