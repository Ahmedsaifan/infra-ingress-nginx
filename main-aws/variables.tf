variable "aws_region" {
  description = "AWS region"
}
variable "aws_role_arn" {
  description = "admin role arn"
}

variable "cluster_name" {
  description = "EKS cluster name"
}


variable "ign_helm_version" {
  type = string
  default = "3.24.0"
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