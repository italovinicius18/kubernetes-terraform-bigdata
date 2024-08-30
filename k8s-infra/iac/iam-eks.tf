#==========EKS-EBS-CSI-DRIVER==========#
resource "aws_iam_policy" "ebs_csi_driver_policy" {
  name        = "policy-ebs-csi-driver-${terraform.workspace}"
  description = "Policy for EBS CSI Driver used by EKS"
  tags        = local.common_tags

  policy = file("${path.module}/policies/iam-policy-ebs-csi-driver.json")
}


data "aws_iam_policy_document" "ebs_csi_driver_assume_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
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

resource "aws_iam_role" "web_identity_ebs_csi_driver_role" {
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_driver_assume_policy.json
  name               = "${terraform.workspace}-ebs-csi-driver-role"
  tags               = local.common_tags
}

resource "aws_iam_policy_attachment" "ebs_csi_driver_sa" {
  name       = "ebs-csi-driver-role-${terraform.workspace}"
  roles      = [aws_iam_role.web_identity_ebs_csi_driver_role.name]
  policy_arn = aws_iam_policy.ebs_csi_driver_policy.arn
}