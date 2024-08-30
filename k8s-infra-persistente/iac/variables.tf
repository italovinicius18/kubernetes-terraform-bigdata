variable "region" {
  description = "AWS region to instance content"
  default     = "us-east-1"
}

variable "vpc_id" {
  default = {
    prod = "vpc-"
    dev  = "vpc-"
  }
}

variable "route_table_id" {
  default = {
    prod = "rtb-"
    dev  = "rtb-"
  }
}

variable "vpc_subnets_cidr" {
  default = {
    # É possível que tenha que mudar o range de IP's para não conflitar com o range de IP's das subnets existentes
    prod = {
      airflow = [
        "172.31.1.0/24",
        "172.31.2.0/24",
      ],
      public = [
        "172.31.3.0/24",
        "172.31.7.0/24",
        "172.31.8.0/24"
      ]
    }
    dev = {
      airflow = [
        "172.30.1.0/24",
        "172.30.2.0/24",
      ],
      public = [
        "172.30.3.0/24",
        "172.30.4.0/24",
        "172.30.5.0/24"
      ]
    }
  }
}

variable "cidr_vpn" {
  default = {
    prod = [
    ]
    dev = [
    ]
  }
}

# Prefix configuration and project common tags
locals {
  worker_group_mgmt_one = "worker_group_mgmt_one-${terraform.workspace}"
  sub_group_rds         = "subnetgrouprds-data-${terraform.workspace}"
  common_tags = {
    "Environment" : "eks-${terraform.workspace}",
  }
  airflow_tags = merge(local.common_tags, {
    "Name" = "airflow-${terraform.workspace}"
  })
}