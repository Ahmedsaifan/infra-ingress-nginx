variable "gcp_region" {
  description = "GCP Region"
}
variable "gcp_location" {
  description = "GCP Region or zone"
}
variable "gcp_project" {
  description = "GCP Project"
}

variable "cluster_name" {
  description = "GKE cluster name"
}


variable "ign_helm_version" {
  type = string
  default = "4.3.0"
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
variable "ign_hpa_target_cpu" {
  type = number
  default = 60
}
variable "ign_hpa_target_mem" {
  type = number
  default = 60
}
variable "ign_min_available" {
  type = number
  description = "min available disruption budget"
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
  default = "Local"
}
variable "ign_allow_only_cloudflare" {
  type = bool
  default = false
}
variable "ign_run_cloudflare_ips_check" {
  type = bool
  default = false
}
variable "ign_log_flush" {
  type = string
}

variable "prom_host" {
  type        = string
}
variable "prom_request_cpu" {
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
  default = "letsencrypt"
}


variable "memc_request_memory" {
  type = string
}
variable "memc_cache_size" {
  type = number
}
variable "memc_request_cpu" {
  type = string
}

variable "memc_svc_clusertip" {
  type        = string
}

variable "traefik_svc_clusertip" {
  type        = string
}