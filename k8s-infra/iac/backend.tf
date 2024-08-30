terraform {
  # required_version = "1.7.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.21.1"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 2.0.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0.0"
    }

    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
  }
  backend "s3" {
    encrypt = true
    region  = "us-east-1"
    #bucket, arquivo e região serão inseridos no arquivo de variáveis via gitlab-ci
  }
}
