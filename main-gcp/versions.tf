terraform {
  required_version = "~> 1.8.0"

  required_providers {
    google    = {
      source  = "hashicorp/google"
      version = "4.30.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.15.0"
    }
    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14"
    }
  }
}

