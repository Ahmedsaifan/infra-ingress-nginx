aws_region                    = "eu-west-1"
cluster_name                  = "applications"
aws_role_arn                  = "arn:aws:iam::404549330413:role/eks-applications-full-admin"

ign_replicas                  = 2
ign_hpa_minReplicas           = 3
ign_hpa_maxReplicas           = 10
ign_request_memory            = "2Gi"
ign_request_cpu               = "1.5"


prom_request_cpu    = "500m"
prom_request_memory = "3Gi"
prom_limit_cpu      = "500m"
prom_limit_memory   = "3Gi"