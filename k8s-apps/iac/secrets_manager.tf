data "aws_secretsmanager_secret" "admin_argocd" {
  name = "${upper(terraform.workspace)}-EKS-ADMIN-ARGOCD-PASSWORD"
}

data "aws_secretsmanager_secret_version" "secret_admin_argocd" {
  secret_id = data.aws_secretsmanager_secret.admin_argocd.id
}

data "aws_secretsmanager_secret" "argocd_gitlab_credentials" {
  name = "${upper(terraform.workspace)}-EKS-ARGOCD-GITLAB-CREDENTIALS"
}

data "aws_secretsmanager_secret_version" "secret_argocd_gitlab_credentials" {
  secret_id = data.aws_secretsmanager_secret.argocd_gitlab_credentials.id
}

data "aws_secretsmanager_secret" "airflow_secret_keys" {
  name = "${upper(terraform.workspace)}-EKS-AIRFLOW-CONFIG-SECRET-KEYS"
}

data "aws_secretsmanager_secret_version" "secret_airflow_secret_keys" {
  secret_id = data.aws_secretsmanager_secret.airflow_secret_keys.id
}

data "aws_secretsmanager_secret" "airflow_database_credentials" {
  name = "${upper(terraform.workspace)}-RDS-POSTGRES-CREDENTIALS"
}

data "aws_secretsmanager_secret_version" "secret_airflow_database_credentials" {
  secret_id = data.aws_secretsmanager_secret.airflow_database_credentials.id
}

data "aws_secretsmanager_secret" "aws_credentials_spark" {
  name = "${upper(terraform.workspace)}-SPARK-AWS-CREDENTIALS"
}

data "aws_secretsmanager_secret_version" "secret_aws_credentials_spark" {
  secret_id = data.aws_secretsmanager_secret.aws_credentials_spark.id
}

data "aws_secretsmanager_secret" "user_credentials_grafana" {
  name = "${upper(terraform.workspace)}-EKS-GRAFANA-ADMIN-CREDENTIALS"
}

data "aws_secretsmanager_secret_version" "secret_user_credentials_grafana" {
  secret_id = data.aws_secretsmanager_secret.user_credentials_grafana.id
}