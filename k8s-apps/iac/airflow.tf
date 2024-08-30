data "aws_caller_identity" "current" {}

resource "kubectl_manifest" "airflow-namespace" {
  yaml_body = file("../k8s/manifests/airflow/airflow-namespace.yaml")
}

#Airflow Secret for repo access
resource "kubectl_manifest" "airflow-repo-sync-secret" {
  depends_on = [
    kubectl_manifest.airflow-namespace
  ]
  yaml_body = templatefile(
    "../k8s/manifests/airflow/airflow-repo-sync-secret.yaml",
    {
      GIT_SYNC_USERNAME = base64encode(local.gitlab_user_credentials["username"])
      GIT_SYNC_PASSWORD = base64encode(local.gitlab_user_credentials["password"])
    }
  )
}

resource "kubectl_manifest" "airflow-repo-ssh-secret" {
  depends_on = [
    kubectl_manifest.airflow-namespace
  ]
  yaml_body = templatefile(
    "../k8s/manifests/airflow/airflow-repo-ssh-secret.yaml",
    {
      GIT_SYNC_SSH_KEY = local.gitlab_user_credentials["ssh_priv"]
    }
  )
}

#Airflow Webserver Secret
resource "kubectl_manifest" "airflow-web-server-secret" {
  # To generate the Web Server Secret Key, run the following command in bash:
  # python3 -c 'import secrets; print(secrets.token_hex(16))'
  depends_on = [
    kubectl_manifest.airflow-namespace
  ]
  yaml_body = templatefile(
    "../k8s/manifests/airflow/airflow-webserver-secret.yaml",
    {
      WEBSERVER_SECRET_KEY = base64encode(local.airflow_config_secret_keys["web_server_secret_key"])
    }
  )
}

#Airflow FernetKey Secret
resource "kubectl_manifest" "airflow-fernet-key-secret" {
  # To generate the Fernet Key, run the following commands in python:
  # from cryptography.fernet import Fernet

  # fernet_key = Fernet.generate_key()
  # print(fernet_key.decode())  # your fernet_key, keep it in secured place!
  depends_on = [
    kubectl_manifest.airflow-namespace
  ]
  yaml_body = templatefile(
    "../k8s/manifests/airflow/airflow-fernet-key-secret.yaml",
    {
      FERNET_KEY = base64encode(local.airflow_config_secret_keys["fernet_key"])
    }
  )
}

locals {
  username                            = local.airflow_database_credentials["username"]
  password                            = local.airflow_database_credentials["password"]
  db_name                             = local.airflow_database_credentials["dbname"]
  address                             = data.aws_db_instance.airflow.address
  port                                = data.aws_db_instance.airflow.port
  airflow_postgres_connection_encoded = base64encode("postgresql://${local.username}:${local.password}@${local.address}:${local.port}/${local.db_name}")
}

resource "kubectl_manifest" "airflow-postgres-credentials-secret" {
  depends_on = [
    kubectl_manifest.airflow-namespace
  ]
  yaml_body = templatefile(
    "../k8s/manifests/airflow/airflow-postgres-credentials-secret.yaml",
    {
      CONNECTION_STRING         = local.airflow_postgres_connection_encoded
      AIRFLOW_DB_HOST           = base64encode(local.address)
      AIRFLOW_DB_PORT           = base64encode(local.port)
      AIRFLOW_DB_ADMIN_USER     = base64encode(data.aws_db_instance.airflow.master_username)
      AIRFLOW_DB_ADMIN_DB       = base64encode(data.aws_db_instance.airflow.db_name)
      AIRFLOW_DB_USER           = base64encode(local.username)
      AIRFLOW_DB_PASSWORD       = base64encode(local.password)
      AIRFLOW_DB_NAME           = base64encode(local.db_name)
      AIRFLOW_DB_ADMIN_PASSWORD = base64encode(local.password)
    }
  )
}

data "aws_db_instance" "airflow" {
  db_instance_identifier = local.rds_airflow_identifier
}

locals {
  airflow_role_logs         = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.airflow_aws_role_name}"
  encoded_airflow_role_logs = urlencode(local.airflow_role_logs)
}

# Airflow ArgoCD Application
resource "kubectl_manifest" "argocd-airflow-app" {
  depends_on = [
    helm_release.argocd,
    kubectl_manifest.airflow-repo-sync-secret,
    kubectl_manifest.airflow-web-server-secret,
    kubectl_manifest.airflow-fernet-key-secret,
    kubectl_manifest.airflow-postgres-credentials-secret
  ]

  yaml_body = templatefile(
    "../k8s/manifests/argocd/applications-airflow.yaml",
    {
      REPO_URL                             = var.k8s_repo_url,
      REPO_BRANCH                          = local.infra_repo_branch,
      REPO_PATH                            = "k8s/applications/airflow",
      DAG_SYNC_REPO                        = var.dags_repo_url,
      DAG_SYNC_REPO_BRANCH                 = local.apps_repo_branch,
      DAG_SYNC_REPO_SUB_PATH               = "dags",
      AIRFLOW_LOGGING_BUCKET_PATH          = "s3://${var.logging_bucket_name}/logs/airflow-${terraform.workspace}",
      AWS_DEFAULT_REGION                   = var.region,
      AIRFLOW_ROLE_ARN                     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.airflow_aws_role_name}",
      AIRFLOW_USERNAME                     = local.airflow_config_secret_keys["airflow_webserver_admin_username"]
      AIRFLOW_PASSWORD                     = local.airflow_config_secret_keys["airflow_webserver_admin_password"]
      AIRFLOW_TOLERATIONS                  = local.airflow_tolerations
      AIRFLOW_WEBSERVER_SERVICE_TYPE       = "ClusterIP"
      K8S_POSTGRES_ENABLED                 = "false"
      EXTERNAL_POSTGRES_CREDENTIALS_SECRET = kubectl_manifest.airflow-postgres-credentials-secret.name
      K8S_CLUSTER_AIRFLOW_CONNECTION       = "kubernetes://:@:/?extra__kubernetes__in_cluster=True"
      AWS_AIRFLOW_CONNECTION               = "aws://:@:/?region_name=${var.region}&role_arn=${local.encoded_airflow_role_logs}"
      AIRFLOW_REPOSITORY                   = "apache/airflow"
      AIRFLOW_TAG                          = "2.9.2"
      AIRFLOW_VERSION                      = "2.9.2"
      TF_WORKSPACE                         = terraform.workspace
    }
  )
}

resource "kubectl_manifest" "airflow-ingress" {
  depends_on = [
    kubectl_manifest.argocd-airflow-app
  ]

  yaml_body = templatefile(
    "../k8s/manifests/airflow/airflow-ingress.yaml",
    {
      TF_WORKSPACE = terraform.workspace
    }
  )
}