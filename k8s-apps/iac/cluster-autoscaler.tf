# Cluster Autoscale and Service account
data "kubectl_path_documents" "cluster-autoscaler-autodiscover" {
  pattern = "../k8s/manifests/cluster-autoscaler/cluster-autoscaler-autodiscover.yaml"
  vars = {
    AUTOSCALE_ROLE_ARN = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.cluster_autoscaler_role_name}"
    CLUSTER_NAME       = local.cluster_name
    AWS_REGION         = var.region
  }
}

# Applying Cluster Autoscale Service account
resource "kubectl_manifest" "cluster-autoscaler-applying-autodiscover" {
  count     = length(data.kubectl_path_documents.cluster-autoscaler-autodiscover.documents)
  yaml_body = element(data.kubectl_path_documents.cluster-autoscaler-autodiscover.documents, count.index)
}
