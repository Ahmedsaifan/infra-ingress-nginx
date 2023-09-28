
/*
  DANGER: Don't update if you don't know what you're doing, this might lead to a downtime
  Set externalTrafficPolicy to Cluster before rolling any update

  This error showed up in the cluster events when I set externalTrafficPolicy=Local "error modifying target group health check: "InvalidConfigurationRequest: You cannot change the health check protocol for a target group with the TCP protoco"
  The fix will be released in 1.20 as per this comment https://github.com/kubernetes/kubernetes/issues/80996#issuecomment-698194559
  We can live with this error for the moment
  EKS 1.20 will be released on April, 2021 
  Update plan:
    - Set externalTrafficPolicy: Cluster
    - Upgrade EKS to 1.20
    - Set externalTrafficPolicy: Local

  Note: You should enable cross-zone-load-balancing if externalTrafficPolicy=Local

  ConfigMap:
    "use-forwarded-headers" is set to "true" because most of endpoints are behind CloudFlare or HAProxy. 
    The only possible way to get the real client ip is through the http header x-forwarded-for
*/



data "template_file" "ingress_nginx" {
  template = <<EOF
controller:
  allowSnippetAnnotations: true
  replicaCount: 1
  podLabels:
    "app": "ingress-nginx"
  service:
    labels:
      "app": "ingress-nginx"
    annotations:
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol": "tcp"
      "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled": "false"
      "service.beta.kubernetes.io/aws-load-balancer-type": "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-target-node-labels": "workload=ingress"
      "networking.gke.io/load-balancer-type": "External"
      "cloud.google.com/network-tier": "Standard"
    externalTrafficPolicy: "${var.ign_external_traffic_policy}"
    loadBalancerIP: ${var.ign_lb_ip}
%{ if var.ign_allow_only_cloudflare }
    loadBalancerSourceRanges: 
      ${indent(6, yamlencode(concat(local.cloudflare_expected_ips, local.harbor_authorized_ips)))}
%{ endif }

  metrics:
    enabled: true
    serviceMonitor:
      enabled: true
      additionalLabels:
        release: ${local.prometheusSelector}
      metricRelabelings:
        - sourceLabels: ['__name__']
          regex: (.*)
          targetLabel: datasource
          replacement: Prometheus-ingress-nginx
          action: replace
  resources:
    requests:
      cpu: ${var.ign_request_cpu}
      memory: ${var.ign_request_memory}
  autoscaling:
    enabled: true
    minReplicas: ${var.ign_hpa_minReplicas}
    maxReplicas: ${var.ign_hpa_maxReplicas}
    targetCPUUtilizationPercentage: ${var.ign_hpa_target_cpu}
    targetMemoryUtilizationPercentage: ${var.ign_hpa_target_mem}
    behavior:
      scaleDown:
        stabilizationWindowSeconds: 300
        policies:
        - type: Pods
          value: 1
          periodSeconds: 180
      scaleUp:
        stabilizationWindowSeconds: 0
        policies:
        - type: Pods
          value: 10
          periodSeconds: 60
  minAvailable: ${var.ign_min_available}
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  priorityClassName: ${local.ign_priority_class[var.platform]}
  nodeSelector: 
    workload: ingress
  tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "ingress"
    effect: "NoSchedule"
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
            - ingress-nginx
          - key: app.kubernetes.io/instance
            operator: In
            values:
            - ingress-nginx
          - key: app.kubernetes.io/component
            operator: In
            values:
            - controller
        topologyKey: "kubernetes.io/hostname"
  config:
    #"worker-shutdown-timeout": "1s" ###########################################################only in test
    "worker-processes": "2"
    "max-worker-connections": "2048"
    "access-log-params": "buffer=64k flush=${var.ign_log_flush}"
    "log-format-upstream": "[$time_local] $remote_addr $host \"$request $status $request_time $request_length\" $http_referer $http_user_agent $body_bytes_sent [$ingress_name] [$proxy_upstream_name] $upstream_response_length $upstream_response_time $upstream_status $req_id"
    "use-forwarded-headers": "true"
    "use-gzip": "true"
    "gzip-level": "1"
    "client-header-buffer-size": "16k"
    "client-body-buffer-size": "1024k"
    "large-client-header-buffers": "4 32k"
    "http2-max-field-size": "16k"
    "http2-max-header-size": "16k"
    "client-header-timeout": "8"
    "client-body-timeout": "8"
    "keep-alive": "15"
    "proxy-buffer-size": "32k"
    "limit-req-status-code": "511"
    "limit-conn-status-code": "511"
    "global-rate-limit-status-code": "512"
    "global-rate-limit-memcached-host": "${var.memc_svc_clusertip}"
    "global-rate-limit-memcached-port": "11211"
    "global-rate-limit-memcached-connect-timeout": "200"
    "global-rate-limit-memcached-max-idle-timeout": "60000"
    "global-rate-limit-memcached-pool-size": "2000"

${local.ign_sysctls[var.platform]}
    

EOF

#tuning references
#https://intl.cloud.tencent.com/document/product/457/38300
#https://www.nginx.com/blog/tuning-nginx
}


resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.11.2"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name

  # Default values
  # https://github.com/kubernetes/ingress-nginx/blob/master/charts/ingress-nginx/values.yaml
  values      = [data.template_file.ingress_nginx.rendered]
  max_history = 10


  depends_on = [kubernetes_priority_class.nginx_priority_class]
}






/*
 Using custom pod security policy 
 in order to be able to inject istio sidecars
*/

/*resource "kubernetes_pod_security_policy" "ingress_nginx_custom" {

  metadata {
    name = "ingress-nginx-custom"
    labels = merge(var.shared_k8s_tags, {})
  }
  spec {
    privileged                 = true

    allow_privilege_escalation = true

    allowed_capabilities = [
      "NET_BIND_SERVICE",
      "NET_ADMIN",
      "NET_RAW"
    ]

    volumes = ["*"]

    allowed_unsafe_sysctls = [
      "net.core.somaxconn",
      "net.ipv4.ip_local_port_range",
      "net.ipv4.tcp_tw_reuse"
    ]

    run_as_user {
      rule = "RunAsAny"
    }

    se_linux {
      rule = "RunAsAny"
    }

    supplemental_groups {
      rule = "RunAsAny"
    }

    fs_group {
      rule = "RunAsAny"
    }

  }
}

resource "kubernetes_role" "ingress_nginx_custom" {

  metadata {  
    name = "ingress-nginx-custom"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
    labels = merge(var.shared_k8s_tags, {})
  }

  rule {
    api_groups      = ["policy"]
    resources       = ["podsecuritypolicies"]
    resource_names  = [kubernetes_pod_security_policy.ingress_nginx_custom.metadata[0].name]
    verbs           = ["use"]
  }
}

resource "kubernetes_role_binding" "ingress_nginx_custom" {

  metadata {
    name = "ingress-nginx-custom"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
    labels = merge(var.shared_k8s_tags, {})
  }

  subject {
    kind      = "ServiceAccount"
    name      = "ingress-nginx"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.ingress_nginx_custom.metadata[0].name
  }
}
*/
