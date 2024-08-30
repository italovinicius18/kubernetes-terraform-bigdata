data "aws_iam_policy_document" "cluster_autoscaler_policy" {
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeImages",
      "ec2:GetInstanceTypesFromInstanceRequirements",
      "eks:DescribeNodegroup"
    ]
    effect = "Allow"

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/k8s.io/cluster-autoscaler/${local.cluster_name}"
      values   = ["owned"]
    }
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name        = "eks-cluster-autoscaler-${terraform.workspace}"
  description = "Policy for eks auto-scaler"
  tags        = local.common_tags

  policy = data.aws_iam_policy_document.cluster_autoscaler_policy.json
}

data "aws_iam_policy_document" "cluster_autoscaler_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "web_identity_cluster_autoscaler_role" {
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume_role.json
  name               = "web-identity-eks-cluster-autoscaler-${terraform.workspace}"
  tags               = local.common_tags
}

resource "aws_iam_policy_attachment" "autoscaler_sa" {
  name       = "${terraform.workspace}-autoscaler-role"
  roles      = [aws_iam_role.web_identity_cluster_autoscaler_role.name]
  policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
}
