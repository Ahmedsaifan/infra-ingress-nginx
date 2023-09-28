resource "kubernetes_service_account" "prometheus_ingress_nginx" {

  metadata {
    name      = "prometheus-ingress-nginx"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }
  automount_service_account_token = true
}


resource "kubernetes_cluster_role" "prometheus_ingress_nginx" {

  metadata {
    name = "prometheus-ingress-nginx"
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["pods", "services", "endpoints"]
  }
  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["configmaps"]
  }
}


resource "kubernetes_role_binding" "prometheus_ingress_nginx" {
  metadata {
    name = "prometheus-ingress-nginx"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.prometheus_ingress_nginx.metadata[0].name
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.prometheus_ingress_nginx.metadata[0].name
  }
}

#temporary until we rewrite nc
resource "kubernetes_role_binding" "prometheus_ingress_nginx_2" {
  metadata {
    name = "prometheus-ingress-nginx"
    namespace = local.prom_additional_scrape_ns[var.cluster_name]
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.prometheus_ingress_nginx.metadata[0].name
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.prometheus_ingress_nginx.metadata[0].name
  }
}

resource "kubernetes_role_binding" "prometheus_ingress_nginx_kps" {

  metadata {
    name = "prometheus-ingress-nginx-kps"
    namespace = "kube-prometheus-stack" #to discover alertmanager
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.prometheus_ingress_nginx.metadata[0].name
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.prometheus_ingress_nginx.metadata[0].name
  }
}

resource "kubernetes_ingress_v1" "prometheus_ingress_nginx" {

  metadata {
    name = "prometheus-ingress-nginx"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
    
    annotations = {
      "kubernetes.io/ingress.class"                                   = "nginx"
      "cert-manager.io/cluster-issuer"                                =  var.letsencrypt_issuer
      "nginx.ingress.kubernetes.io/rewrite-target"                    = "/$1"
      "nginx-annotations-injector.galaxy.kubernetes.io/authelia"       = "yes"
    }
  }

  spec {

    rule {
      host = var.prom_host
      http {
        path {
          backend {
            service {
              name = "prometheus-operated"
              port {
                number = 9090
              }
            }
          }
          path = "/ingress-nginx/(.*)"
        }
      }
    }

    tls {
      secret_name = "prometheus-nginx-ingress-tls"
      hosts = [var.prom_host]
    }
  }
}


resource "kubectl_manifest" "ingress_nginx_prometheus" {
    yaml_body = <<YAML
kind: Prometheus
apiVersion: monitoring.coreos.com/v1
metadata:
  name: prometheus-ingress-nginx
  namespace: ${kubernetes_namespace.ingress_nginx.metadata[0].name}
  labels:
    app: prometheus-ingress-nginx
    release: ${local.prometheusSelector}
spec:
  alerting:
    alertmanagers:
      - apiVersion: v2
        name: kps-kube-prometheus-stack-alertmanager
        namespace: kube-prometheus-stack
        pathPrefix: /
        port: http-web
  enableAdminAPI: true
  externalUrl: 'https://${var.prom_host}/ingress-nginx'
  version: v2.31.1
  listenLocal: false
  logFormat: logfmt
  logLevel: info
  podMonitorNamespaceSelector: {}
  podMonitorSelector:
    matchLabels:
      release: ${local.prometheusSelector}
  portName: http-web
  probeNamespaceSelector: {}
  probeSelector:
    matchLabels:
      release: ${local.prometheusSelector}
  replicas: 1
  resources:
    requests:
      cpu: ${var.prom_request_cpu}
      memory: ${var.prom_request_memory}
  retention: 1d
  routePrefix: /
  ruleNamespaceSelector: {}
  ruleSelector:
    matchLabels:
      release: ${local.prometheusSelector}
  serviceMonitorNamespaceSelector: {}
  serviceMonitorSelector:
    matchLabels:
      release: ${local.prometheusSelector}
  storage:
    volumeClaimTemplate:
      spec:
        resources:
          requests:
            storage: 5Gi
        storageClassName: ssd-retain
  serviceAccountName: ${kubernetes_service_account.prometheus_ingress_nginx.metadata[0].name}
  securityContext:
    fsGroup: 2000
    runAsGroup: 2000
    runAsNonRoot: true
    runAsUser: 1000
  remoteWrite:
    - url: http://vminsert-vmcluster.victoria-operator.svc.cluster.local:8480/insert/0/prometheus/api/v1/write
      queueConfig:
        capacity: 20000
        maxSamplesPerSend: 10000
        maxShards: 30

YAML
}



# add prometheus-ingress to grafana
resource "kubernetes_config_map" "grafana_datasource_prometheus_haproxy" {
  metadata {
    name = "grafana-datasource-nginx-ingress"
    namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
    labels = merge(var.shared_k8s_tags, {
      "app.kubernetes.io/managed-by" = "Terraform"
      "grafana_datasource" = 1
    })
  }

  data = {
    "nginx-ingress.yaml" = <<EOF
apiVersion: 1
datasources:
  - name: Prometheus-nginx-ingress
    type: prometheus
    url: http://prometheus-operated.ingress-nginx.svc:9090
    access: proxy
    isDefault: false
    editable: true
EOF
  }
}
