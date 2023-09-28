/*
    Workaround to clean core dump files
*/


resource "kubernetes_service_account" "ign_core_cleaner" {
  metadata {
    name      = "sa-ign-core-cleaner"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
    labels = merge(var.shared_k8s_tags, {})
  }
}
resource "kubernetes_role" "ign_core_cleaner" {

  metadata {
    name      = "role-ign-core-cleaner"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
    labels = merge(var.shared_k8s_tags, {})
  }

  rule {
    verbs      = ["get", "list"]
    api_groups = [""]
    resources  = ["pods"]
  }

  rule {
    verbs      = ["create"]
    api_groups = [""]
    resources  = ["pods/exec"]
  }

}
resource "kubernetes_role_binding" "ign_core_cleaner" {
  metadata {
    name      = "rb-ign-core-cleaner"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
    labels = merge(var.shared_k8s_tags, {})
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.ign_core_cleaner.metadata[0].name
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.ign_core_cleaner.metadata[0].name
  }

}


resource "kubernetes_cron_job_v1" "ign_core_cleaner" {
  metadata {
    name      = "ign-core-cleaner"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
    labels = merge(var.shared_k8s_tags, {})
  }

  spec {
    schedule           = "0 */6 * * *"
    concurrency_policy = "Allow"
    suspend            = true
    successful_jobs_history_limit = 2
    failed_jobs_history_limit     = 2

    job_template {
      metadata {}

      spec {
        template {
          metadata {}

          spec {
            service_account_name = kubernetes_service_account.ign_core_cleaner.metadata[0].name
            automount_service_account_token = true

            container {
              name    = "ign-core-cleaner"
              image   = "odaniait/aws-kubectl:latest"
              command = ["/bin/sh", "-c", <<EOT
for pod in $(kubectl get pods | grep "ingress-nginx-controller" | awk '{print $1}'); do 
  kubectl exec -i $pod -- sh -c 'rm -f core.*' ; 
done
EOT
              ]


              image_pull_policy        = "IfNotPresent"
            }

            restart_policy                   = "Never"
            termination_grace_period_seconds = 60
            dns_policy                       = "Default"
            host_network                     = true
          }
        }
      }
    }
  }
}
