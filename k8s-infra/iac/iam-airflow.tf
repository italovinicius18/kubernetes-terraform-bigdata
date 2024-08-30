data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "airflow_policy" {
  name        = "eks-airflow-${terraform.workspace}"
  description = "Policy for Airflow on EKS"
  tags        = local.common_tags

  policy = file("${path.module}/policies/iam-policy-airflow.json")
}

data "aws_iam_policy_document" "airflow_assume_role_policy_base" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["eks.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "web_identity_airflow_role" {
  name               = "web-identity-eks-airflow-role-${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.airflow_assume_role_policy_base.json
  tags               = local.common_tags

  lifecycle {
    ignore_changes = [
      assume_role_policy
    ]
  }
}

resource "aws_iam_policy_attachment" "airflow_s3_policy" {
  name       = "airflow-s3-policy-${terraform.workspace}"
  roles      = [aws_iam_role.web_identity_airflow_role.name]
  policy_arn = aws_iam_policy.airflow_policy.arn
}

data "template_file" "assume_role_policy" {
  template = file("${path.module}/policies/iam-assume-role-policy-airflow.json")
  vars = {
    EKS_OIDC_PROVIDER_ARN   = module.eks.oidc_provider_arn,
    EKS_OIDC_ISSUER_URL_SUB = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub",
    EKS_OIDC_ISSUER_URL_AUD = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud",
    AIRFLOW_ROLE_ARN        = aws_iam_role.web_identity_airflow_role.arn
  }
}

resource "null_resource" "update_role_policy" {
  triggers = {
    role_id = aws_iam_role.web_identity_airflow_role.unique_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws iam update-assume-role-policy --role-name ${aws_iam_role.web_identity_airflow_role.name} --policy-document '${data.template_file.assume_role_policy.rendered}'
    EOT
  }
}