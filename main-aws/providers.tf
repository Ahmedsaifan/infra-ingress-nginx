provider "aws" {
  region  = var.aws_region
}

data "aws_eks_cluster" "cluster" {
  name    = var.cluster_name
}



provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command = "aws-iam-authenticator"
    args = ["token", "-i", var.cluster_name]
  }
  ignore_annotations = [
    "downscaler\\/exclude-until",
  ]
}


provider "helm" {
  helm_driver = "configmap"
  debug = false
  
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      command = "aws-iam-authenticator"
      args = ["token", "-i", var.cluster_name]
    }
  }
  
}

