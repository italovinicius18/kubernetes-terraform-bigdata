module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "19.15.2"
  cluster_name                    = local.cluster_name
  cluster_version                 = "1.29"
  vpc_id                          = var.vpc_id[terraform.workspace]
  subnet_ids                      = aws_subnet.eks_subnet_public[*].id
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  # cluster_endpoint_public_access_cidrs = var.cidr_vpn[terraform.workspace]
  tags                             = local.common_tags
  enable_irsa                      = true
  create_kms_key                   = false
  cluster_encryption_config        = {}
  create_cloudwatch_log_group      = false
  cluster_enabled_log_types        = []
  attach_cluster_encryption_policy = false

  cluster_addons = {
    aws-ebs-csi-driver = {
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = aws_iam_role.web_identity_ebs_csi_driver_role.arn
      addon_version               = "v1.30.0-eksbuild.1"
    }

    vpc-cni = {
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = module.vpc_cni_irsa.iam_role_arn
      most_recent                 = true
      before_compute              = true
    }
  }

  eks_managed_node_group_defaults = {
    iam_role_attach_cni_policy = true

    attach_cluster_primary_security_group = true

    create_security_group = false

    iam_role_additional_policies = {
      additional_a = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
      additional_b = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
      additional_c = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
    }
  }

  node_security_group_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = null,
  }

  eks_managed_node_groups = {
    apps = {
      name                   = "${terraform.workspace}-worker-group-apps"
      instance_types         = [var.instance_type[terraform.workspace]["apps"]["instance"]]
      ami_type               = var.instance_type[terraform.workspace]["apps"]["ami"]
      capacity_type          = "ON_DEMAND"
      min_size               = terraform.workspace == "prod" ? 3 : 3
      desired_size           = terraform.workspace == "prod" ? 3 : 3
      max_size               = 5
      vpc_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      tags = {
        "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
        "k8s.io/cluster-autoscaler/enabled"               = "TRUE"
        "kind"                                            = "apps"
      }

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 100
            volume_type           = "gp2"
            encrypted             = false
            delete_on_termination = true
          }
        }
      }
    }


    jobs = {
      name                   = "${terraform.workspace}-worker-group-jobs"
      instance_types         = [var.instance_type[terraform.workspace]["jobs"]["instance"]]
      ami_type               = var.instance_type[terraform.workspace]["jobs"]["ami"]
      capacity_type          = "ON_DEMAND"
      min_size               = terraform.workspace == "prod" ? 3 : 2
      desired_size           = terraform.workspace == "prod" ? 3 : 3
      max_size               = 5
      vpc_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      tags = {
        "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
        "k8s.io/cluster-autoscaler/enabled"               = "TRUE"
        "kind"                                            = "jobs"
      }

      # Taints são usados para garantir que determinados pods sejam executados em instâncias específicas
      # Isso é útil para garantir que jobs críticos não sejam executados em instâncias de menor capacidade
      # No caso abaixo, todos os pods que possuem a taint "dedicated=jobs" só serão executados em instâncias que possuem a taint "dedicated=jobs"
      # Evita que os pods de aplicações sejam executados em instâncias de jobs
      taints = {
        "dedicated" = {
          key    = "dedicated"
          value  = "jobs"
          effect = "NO_SCHEDULE"
        }
      }

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 100
            volume_type           = "gp2"
            encrypted             = false
            delete_on_termination = true
          }
        }
      }
    }
  }

  create_aws_auth_configmap = false
  manage_aws_auth_configmap = false
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 4.12"

  role_name_prefix      = "VPC-CNI-IRSA"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true # NOTE: This was what needed to be added

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}

# Existe um bug no módulo do terraform-aws-modules/eks/aws que não permite a criação do aws-auth configmap depois que um apply foi feito.
# Para corrigir isto, depois do primeiro apply é necessário comentar o bloco abaixo e remover o resource "kubernetes_config_map_v1_data" do tfstate.

# resource "kubernetes_config_map_v1_data" "aws_auth" {
#   depends_on = [module.eks.eks_managed_node_groups]
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }
#   data = {
#     mapAccounts = jsonencode([])
#     mapUsers    = replace(yamlencode(distinct(terraform.workspace == "prod" ? var.map_users_prod : var.map_users_dev)), "\"", "")
#     mapRoles = replace(yamlencode(distinct([
#       {
#         rolearn  = module.eks.eks_managed_node_groups["green"].iam_role_arn
#         username = "system:node:{{EC2PrivateDNSName}}"
#         groups   = ["system:bootstrappers", "system:nodes"]
#       },
#     ])), "\"", "")
#   }

#   # lifecycle {
#   #   ignore_changes = [data["mapRoles"]]
#   # }
# }
