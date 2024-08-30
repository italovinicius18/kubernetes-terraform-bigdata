data "kubectl_file_documents" "cluster_metrics" {
  content = file("../k8s/manifests/metrics-server/metrics-components.yaml")
}

resource "kubectl_manifest" "cluster_metrics" {
  count     = length(data.kubectl_file_documents.cluster_metrics.documents)
  yaml_body = element(data.kubectl_file_documents.cluster_metrics.documents, count.index)
}
