resource "kubectl_manifest" "argocd-namespace" {
  yaml_body = file("../k8s/manifests/argocd/argocd-namespace.yaml")
}

data "kubectl_path_documents" "argocd-repositories" {
  pattern = "../k8s/manifests/argocd/argocd-repositories-secret.yaml"
  vars = {
    REPO_NAME     = "k8s-apps"
    REPO_URL      = var.k8s_repo_url
    REPO_USERNAME = local.gitlab_user_credentials["username"]
    REPO_PASSWORD = local.gitlab_user_credentials["password"]
  }
}
resource "kubectl_manifest" "argocd-repositories" {
  depends_on = [
    kubectl_manifest.argocd-namespace
  ]
  count              = length(data.kubectl_path_documents.argocd-repositories.documents)
  yaml_body          = element(data.kubectl_path_documents.argocd-repositories.documents, count.index)
  sensitive_fields   = ["stringData.username", "stringData.password"]
  override_namespace = "argocd"
}

resource "helm_release" "argocd" {
  depends_on = [helm_release.aws-load-balancer-controller, kubectl_manifest.argocd-namespace]
  name       = "argocd"
  chart      = "../k8s/applications/argo-cd"
  namespace  = kubectl_manifest.argocd-namespace.name
  wait       = false
  # set {
  #   name  = "server.service.type"
  #   value = "LoadBalancer"
  # }

  # set {
  #   name  = "server.ingress.enabled"
  #   value = "true"
  # }
  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = local.admin_argocd["password_bcrypt"]
  }
  set {
    name  = "configs.params.server.insecure"
    value = "true"
  }
  set {
    name  = "redis.enabled"
    value = "true"
  }
  #   set_sensitive {
  #     name  = "externalRedis.host"
  #     value = ""
  #   }
  #   set_sensitive {
  #     name  = "externalRedis.port"
  #     value = ""
  #   }
}

# resource "kubectl_manifest" "argocd-ingress" {
#   depends_on = [
#     helm_release.argocd,
#   ]

#   yaml_body = templatefile(
#     "../k8s/manifests/argocd/argocd-ingress.yaml",
#     {
#       TF_WORKSPACE = terraform.workspace
#     }
#   )
# }