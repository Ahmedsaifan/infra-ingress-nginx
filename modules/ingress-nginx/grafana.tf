


resource "kubernetes_config_map" "grafana_dashboard_nginx" {
  metadata {
    name = "grafana-dashboard-nginx"
    namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
    labels = merge(var.shared_k8s_tags, { 
      "app.kubernetes.io/managed-by" = "Terraform"
      "grafana_dashboard" = 1
      "based_on" = "github.com_ingress-nginx_nginx.json"
    })
    annotations = {
      "sidecar.grafana.com/dashboard-folder" = var.github_repo
    }
  }

  data = {
    "nginx.json" = file("${path.module}/grafana-dashboards/nginx.json")
  }
}
resource "kubernetes_config_map" "grafana_dashboard_nginx_request_handling_performance" {
  metadata {
    name = "grafana-dashboard-nginx-request-handling-performance"
    namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
    labels = merge(var.shared_k8s_tags, { 
      "app.kubernetes.io/managed-by" = "Terraform"
      "grafana_dashboard" = 1
      "based_on" = "github.com_ingress-nginx_request-handling-performance.json"
    })
    annotations = {
      "sidecar.grafana.com/dashboard-folder" = var.github_repo
    }
  }

  data = {
    "nginx-request-handling-performance.json" = file("${path.module}/grafana-dashboards/nginx-request-handling-performance.json")
  }
}


resource "kubernetes_config_map" "grafana_dashboard_nginx_traffic" {
  metadata {
    name = "grafana-dashboard-nginx-traffic"
    namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
    labels = merge(var.shared_k8s_tags, { 
      "app.kubernetes.io/managed-by" = "Terraform"
      "grafana_dashboard" = 1
    })
    annotations = {
      "sidecar.grafana.com/dashboard-folder" = var.github_repo
    }
  }

  data = {
    "nginx-traffic.json" = file("${path.module}/grafana-dashboards/nginx-traffic.json")
  }
}


resource "kubernetes_config_map" "grafana_dashboard_nginx_connections" {
  metadata {
    name = "grafana-dashboard-nginx-connections"
    namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
    labels = merge(var.shared_k8s_tags, { 
      "app.kubernetes.io/managed-by" = "Terraform"
      "grafana_dashboard" = 1
    })
    annotations = {
      "sidecar.grafana.com/dashboard-folder" = var.github_repo
    }
  }

  data = {
    "nginx-connections.json" = file("${path.module}/grafana-dashboards/nginx-connections.json")
  }
}



resource "kubernetes_config_map" "grafana_dashboard_nginx_logs" {
  metadata {
    name = "grafana-dashboard-nginx-logs"
    namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
    labels = merge(var.shared_k8s_tags, { 
      "app.kubernetes.io/managed-by" = "Terraform"
      "grafana_dashboard" = 1
    })
    annotations = {
      "sidecar.grafana.com/dashboard-folder" = var.github_repo
    }
  }

  data = {
    "nginx-logs.json" = file("${path.module}/grafana-dashboards/logs.json")
  }
}