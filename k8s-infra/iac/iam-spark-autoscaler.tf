resource "aws_iam_policy" "worker_policy" {
  name        = "eks-policy-spark-${terraform.workspace}"
  description = "Policy for Spark on EKS"
  tags        = local.common_tags

  policy = file("${path.module}/policies/iam-policy-spark.json")
}

data "aws_iam_policy_document" "spark_scaler_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:processing:spark"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "web_identity_spark_autoscaler_role" {
  name               = "web-identity-eks-spark-autoscaler-${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.spark_scaler_assume_role_policy.json
  tags               = local.common_tags
}


resource "aws_iam_policy_attachment" "spark_autoscaler_policy" {
  name       = "spark-autoscaler-policy-${terraform.workspace}"
  roles      = [aws_iam_role.web_identity_spark_autoscaler_role.name]
  policy_arn = aws_iam_policy.worker_policy.arn
}