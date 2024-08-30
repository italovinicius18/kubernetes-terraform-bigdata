variable "region" {
  description = "aws region to instance content"
  default     = "us-east-1"
}

variable "k8s_repo_url" {
  # Url de exemplo
  default     = "https://gitlab.com.br/data-lake/infraestrutura/k8s-apps.git"
  description = "url desse repositorio"
}

variable "dags_repo_url" {
  # Url de exemplo
  default     = "ssh://git@gitlab.com.br/data-lake/processamento/k8s-airflow-dags.git"
  description = "url do repositorio de dags"
}

variable "logging_bucket_name" {
  default     = "airflow-logs-dev"
  description = "Bucket onde Airflow vai enviar os logs das tasks"
}

variable "vpc_id" {
  default = {
    prod = "vpc-"
    dev  = "vpc"
  }
}

locals {
  gitlab_user_credentials      = jsondecode(data.aws_secretsmanager_secret_version.secret_argocd_gitlab_credentials.secret_string)
  airflow_config_secret_keys   = jsondecode(data.aws_secretsmanager_secret_version.secret_airflow_secret_keys.secret_string)
  airflow_database_credentials = jsondecode(data.aws_secretsmanager_secret_version.secret_airflow_database_credentials.secret_string)
  admin_argocd                 = jsondecode(data.aws_secretsmanager_secret_version.secret_admin_argocd.secret_string)
  spark_aws_credentials        = jsondecode(data.aws_secretsmanager_secret_version.secret_aws_credentials_spark.secret_string)
  grafana_admin_credentials    = jsondecode(data.aws_secretsmanager_secret_version.secret_user_credentials_grafana.secret_string)
  rds_airflow_identifier       = "airflow-${terraform.workspace}"
  # Pods do Airflow toleram apenas nós com a label "dedicated=jobs"
  airflow_tolerations          = "jobs"
  infra_repo_branch            = terraform.workspace == "prod" ? "main" : "dev"
  apps_repo_branch             = terraform.workspace == "prod" ? "main" : "dev"
  airflow_aws_role_name        = "web-identity-eks-airflow-role-${terraform.workspace}"
  spark_aws_role_name          = "web-identity-eks-spark-autoscaler-${terraform.workspace}"
  cluster_autoscaler_role_name = "web-identity-eks-cluster-autoscaler-${terraform.workspace}"
}
