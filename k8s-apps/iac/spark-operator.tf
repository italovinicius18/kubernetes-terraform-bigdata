resource "kubectl_manifest" "spark-namespace" {
  yaml_body = file("../k8s/manifests/spark-operator/spark-namespace.yaml")
}

# Spark Service account and Cluster Role Binding
data "kubectl_path_documents" "spark-service-account" {
  pattern = "../k8s/manifests/spark-operator/spark-service-account.yaml"
  vars = {
    SPARK_ROLE_ARN = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.spark_aws_role_name}"
  }
}

resource "kubectl_manifest" "spark-service-account" {
  depends_on = [
    kubectl_manifest.spark-namespace
  ]
  count     = length(data.kubectl_path_documents.spark-service-account.documents)
  yaml_body = element(data.kubectl_path_documents.spark-service-account.documents, count.index)
}

#Spark AWS Credentials
resource "kubectl_manifest" "spark-aws-credentials" {
  depends_on = [
    kubectl_manifest.spark-namespace
  ]
  yaml_body = templatefile(
    "../k8s/manifests/spark-operator/spark-aws-crendentials-secret.yaml",
    {
      AWS_ACCESS_KEY_ID     = base64encode(local.spark_aws_credentials["aws_access_key_id"])
      AWS_SECRET_ACCESS_KEY = base64encode(local.spark_aws_credentials["aws_secret_access_key"])
    }
  )
}

resource "kubectl_manifest" "spark-repo-ssh-secret" {
  depends_on = [
    kubectl_manifest.spark-namespace
  ]
  yaml_body = templatefile(
    "../k8s/manifests/spark-operator/spark-repo-secrets.yaml",
    {
      GIT_SYNC_SSH_KEY = local.gitlab_user_credentials["ssh_priv"]
    }
  )
}

# ArgoCD Application
resource "kubectl_manifest" "spark-operator-app" {
  depends_on = [
    kubectl_manifest.spark-namespace,
    kubectl_manifest.spark-service-account,
    helm_release.argocd
  ]
  yaml_body = templatefile(
    "../k8s/manifests/argocd/applications-spark-operator.yaml",
    {
      REPO_URL           = var.k8s_repo_url,
      REPO_BRANCH        = local.infra_repo_branch,
      REPO_PATH          = "k8s/applications/spark-operator",
      SPARK_OPERATOR_TAG = "v1beta2-1.3.8-3.1.1"
    }
  )
}
