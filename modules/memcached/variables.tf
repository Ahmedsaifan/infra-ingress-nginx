variable "cluster_name" {
  type = string
  description = "cluster name"
}

variable "github_repo" {
}
variable "shared_k8s_tags" {
}

variable "ign_namespace" {
  type = string
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