resource "kubectl_manifest" "monitoring-namespace" {
  yaml_body = file("../k8s/manifests/prometheus/monitoring-namespace.yaml")
}

# Prometheus ArgoCD Application
resource "kubectl_manifest" "prometheus-application" {
  depends_on = [
    helm_release.argocd,
    kubectl_manifest.monitoring-namespace
  ]
  yaml_body = templatefile(
    "../k8s/manifests/argocd/applications-prometheus.yaml",
    {
      REPO_URL    = var.k8s_repo_url,
      REPO_BRANCH = local.infra_repo_branch,
      REPO_PATH   = "k8s/applications/prometheus"
    }
  )
}