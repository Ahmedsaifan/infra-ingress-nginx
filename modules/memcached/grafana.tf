resource "kubernetes_config_map" "grafana_dashboard_memcached" {
  metadata {
    name = "grafana-dashboard-memcached"
    namespace  = var.ign_namespace
    labels = merge(var.shared_k8s_tags, { 
      "app.kubernetes.io/managed-by" = "Terraform"
      "grafana_dashboard" = 1
      "based_on" = "3063"
    })
    annotations = {
      "sidecar.grafana.com/dashboard-folder" = var.github_repo
    }
  }

  data = {
    "memcached.json" = file("${path.module}/grafana-dashboards/memcached.json")
  }
}