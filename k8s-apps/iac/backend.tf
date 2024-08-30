terraform {
  # required_version = "1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0.1"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
  }
  backend "s3" {
    encrypt = true
    region  = "us-east-1"
    #bucket, arquivo e região serão inseridos no arquivo de variáveis via gitlab-ci
  }
}
