resource "kubectl_manifest" "rules" {
  yaml_body = <<YAML
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: memcached.rules
  namespace: ${var.ign_namespace}
  labels:
    release: prometheus-ingress-nginx
spec:
  groups:
    - name: memcached.rules
      rules:
        - alert: MemcachedInstanceDown
          expr: memcached_up{} == 0
          for: 1m
          labels:
            slack: alerts-gcp-pro-red
            repo: ${var.github_repo}
            severity: critical
          annotations:
            summary: Memcached nginx ingress is down 
            description: Memcached instance is not responding for 1 minute.

        - alert: MemcachedHighMemoryUsage
          expr: (memcached_current_bytes / memcached_limit_bytes) * 100 > 80
          for: 1m
          labels:
            severity: critical
            slack: alerts-gcp-pro-red
            repo: ${var.github_repo}
          annotations:
            summary: Memcached nginx ingress high memory usage
            description: "Memcached memory usage is above 80% for 1 minutes"

        - alert: MemcachedHighRejectedConnections
          expr: increase(memcached_connections_rejected_total[1m]) > 10
          for: 1m
          labels:
            severity: critical
            slack: alerts-gcp-pro-red
            repo: ${var.github_repo}
          annotations:
            summary: Memcached nginx ingress high rejected connections
            description: "Memcached rejected connections are high in the last 1 minutes"

YAML
}