data "template_file" "memcached" {
  template = <<EOF

resources:
  requests:
    memory: ${var.memc_request_memory}
    cpu: ${var.memc_request_cpu}

service:
  clusterIP: ${var.memc_svc_clusertip}

extraEnvVars:
  - name: MEMCACHED_CACHE_SIZE
    value: "${var.memc_cache_size}"
  - name: MEMCACHED_MAX_CONNECTIONS
    value: "60000"

%{ if var.cluster_name == "applications" }
nodeSelector: 
  workload: ingress-memca
%{ endif }

tolerations:
- key: "dedicated"
  operator: "Equal"
  value: "ingress-memca"
  effect: "NoSchedule"


podSecurityContext:
  enabled: true
  fsGroup: 1001
  sysctls:
  - name: net.ipv4.ip_local_port_range
    value: "1024 60999"


metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: "3s"
    labels:
      release: prometheus-ingress-nginx
    jobLabel: ingress-nginx


EOF

#tuning references
#https://intl.cloud.tencent.com/document/product/457/38300
#https://www.nginx.com/blog/tuning-nginx
}


resource "helm_release" "memcached" {
  name       = "memcached"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "memcached"
  version    = "6.3.13"
  namespace  = var.ign_namespace

  # Default values
  # https://github.com/bitnami/charts/blob/main/bitnami/memcached/values.yaml
  values      = [data.template_file.memcached.rendered]
  max_history = 5


}
