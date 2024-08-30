#Grafana user credentials
resource "kubectl_manifest" "grafana-user-secret" {
  depends_on = [
    kubectl_manifest.monitoring-namespace
  ]
  yaml_body = templatefile(
    "../k8s/manifests/grafana/grafana-credentials-secret.yaml",
    {
      GRAFANA_ADMIN_USER     = base64encode(local.grafana_admin_credentials["user"])
      GRAFANA_ADMIN_PASSWORD = base64encode(local.grafana_admin_credentials["password"])
    }
  )
}

# Grafana ArgoCD Application
resource "kubectl_manifest" "grafana-application" {
  depends_on = [
    helm_release.argocd,
    kubectl_manifest.grafana-user-secret
  ]

  yaml_body = templatefile(
    "../k8s/manifests/argocd/applications-grafana.yaml",
    {
      REPO_URL     = var.k8s_repo_url,
      REPO_BRANCH  = local.infra_repo_branch,
      REPO_PATH    = "k8s/applications/grafana",
      TF_WORKSPACE = terraform.workspace
    }
  )
}

# resource "kubectl_manifest" "grafana-ingress" {
#   depends_on = [
#     kubectl_manifest.grafana-application,
#   ]

#   yaml_body = templatefile(
#     "../k8s/manifests/grafana/grafana-ingress.yaml",
#     {
#       TF_WORKSPACE = terraform.workspace
#     }
#   )
# }