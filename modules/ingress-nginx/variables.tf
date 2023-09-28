variable "platform" { 
  type = string
  validation {
    condition     = length(regexall("^(aws|gcp)$", var.platform)) > 0
    error_message = "ERROR: Valid types are \"aws\" and \"gcp\"!"
  }
}

variable "cluster_name" {
  description = "EKS cluster name"
}
variable "github_repo" {
}
variable "shared_k8s_tags" {
}




variable "ign_helm_version" {
  type = string
  description = "Ingress nginx version"
}

variable "ign_replicas" {
  type = number
  default = 1
  description = "Ingress nginx replicas"
}

variable "ign_hpa_minReplicas" {
  type = number
  default = 1
  description = "Ingress nginx HPA min Replica"
}
variable "ign_hpa_maxReplicas" {
  type = number
  default = 2
  description = "Ingress nginx HPA max Replica"
}

variable "ign_min_available" {
  type = number
  description = "min available disruption budget"
}

variable "ign_hpa_target_cpu" {
  type = number
}
variable "ign_hpa_target_mem" {
  type = number
}
variable "ign_request_memory" {
  type = string
  default = "256Mi"
}
variable "ign_request_cpu" {
  type = string
  default = "100m"
}
variable "ign_limit_memory" {
  type = string
  default = "256Mi"
}
variable "ign_limit_cpu" {
  type = string
  default = "100m"
}
variable "ign_use_service_upstream" {
  type = bool
  default = false
}
variable "ign_external_traffic_policy" {
  type = string
  default = "Cluster"
}
variable "ign_allow_only_cloudflare" {
  type = bool
}
variable "ign_run_cloudflare_ips_check" {
  type = bool
}
variable "ign_log_flush" {
  type = string
}
variable "ign_lb_ip" {
  type = string
}


variable "prom_request_cpu" {
  type        = string
}
variable "prom_host" {
  type        = string
}
variable "prom_request_memory" {
  type        = string
}
variable "prom_limit_cpu" {
  type        = string
}
variable "prom_limit_memory" {
  type        = string
}

variable "letsencrypt_issuer" {
  type        = string
  default     = "letsencrypt-cloudflare"
}

variable "memc_svc_clusertip" {
  type        = string
}

variable "traefik_svc_clusertip" {
  type        = string
}