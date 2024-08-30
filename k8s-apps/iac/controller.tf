resource "helm_release" "aws-load-balancer-controller" {
  depends_on = [aws_iam_role_policy_attachment.aws_load_balancer_controller_attach]
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = local.cluster_name
  }

  set {
    name  = "image.tag"
    value = "v2.8.1"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_load_balancer_controller.arn
  }

  set {
    name  = "enableServiceMutatorWebhook"
    value = "false"
  }

  set {
    name  = "region"
    value = var.region
  }
}