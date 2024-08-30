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
      "3.210.153.27/32",  # VPN
      "34.193.17.254/32", # VPN
      "35.173.41.26/32",  # VPN
      "44.221.38.208/32", # VPN
      "54.221.110.96/32"  # GITLAB Runner
    ]
    dev = [
      "34.193.17.254/32",  # VPN
      "34.192.23.163/32",  # VPN
      "52.205.128.170/32", # VPN
      "34.237.36.25/32",   # VPN
      "54.221.110.96/32"   # GITLAB Runner
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

variable "instance_type" {
  description = "Instance type to be used in the worker group"
  default = {
    prod = {
      "apps" = {
        "instance" = "m6i.xlarge",
        "ami"      = "AL2_x86_64"
      }
      "jobs" = {
        "instance" = "m6i.xlarge",
        "ami"      = "AL2_x86_64"
      }
    }
    dev = {
      "apps" = {
        "instance" = "m6i.xlarge",
        "ami"      = "AL2_x86_64"
      }
      "jobs" = {
        "instance" = "m6i.2xlarge",
        "ami"      = "AL2_x86_64"
      }
    }
  }
}

variable "map_users_dev" {
  description = "Additional IAM users to add to the aws-auth configmap on dev cluster."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = [
    {
      userarn  = "arn:aws:iam::065094855987:user/italo.guimaraes"
      username = "italo.guimaraes"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::065094855987:user/jonatas.santoro"
      username = "jonatas.santoro"
      groups   = ["system:masters"]
    }
  ]

}

variable "map_users_prod" {
  description = "Additional IAM users to add to the aws-auth configmap on prod cluster."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = [
    {
      userarn  = "arn:aws:iam::065094855987:user/italo.guimaraes"
      username = "italo.guimaraes"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::065094855987:user/jonatas.santoro"
      username = "jonatas.santoro"
      groups   = ["system:masters"]
    }
  ]
}

# variable "map_roles" {
#   description = "Additional IAM roles to add to the aws-auth configmap."
#   type        = list(object({
#     rolearn  = string
#     username = string
#     groups   = list(string)
#   }))

#   default = [
#     {
#       rolearn  = "arn:aws:iam::065094855987:user/italo.guimaraes"
#       username = "italo.guimaraes"
#       groups   = ["system:masters"]
#     }
#   ]
# }
