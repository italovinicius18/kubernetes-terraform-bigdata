## Kubernetes com Big Data


Este repositório contém o código Terraform e os scripts necessários para provisionar uma infraestrutura do Kubernetes na AWS e implantar um ambiente de big data baseado em Apache Airflow e Spark usando ArgoCD e Helm.

**Estrutura do Repositório**

* **Arquitetura.png:** Diagrama de arquitetura do ambiente de Big Data.
* **Migração de arquitetura.png:** (Opcional) Diagrama de uma versão anterior da arquitetura que usava EMR.
* **k8s-airflow-dags:** Diretório contendo o código Python para os DAGs do Apache Airflow executados no cluster Kubernetes:
    * **dags:** Diretório contendo os arquivos Python das DAGs.
        * **dag-spark-simples.py:** Exemplo de um DAG simples que executa uma tarefa Spark da pasta scripts.
        * **manifests:** Diretório contendo os manifestos do Kubernetes para as aplicações Spark que são implantadas pelo DAG.
            * **spark-pesado-v2.yaml:** Manifesto para uma implantação Spark pesada com as configurações de recursos.
    * **docker:** Diretório contendo o Dockerfile e o requirements.txt para a imagem Docker usada pelo manifesto Spark do DAG.
        * **Dockerfile:** Instruções para construir a imagem Docker do Spark.
        * **requirements.txt:** Dependências do Python necessárias para a imagem Docker do Spark.
    * **scripts:** Diretório contendo scripts usados para gerenciar os DAGs do Airflow.
        * **spark-teste-pesado.py:** Script Pyspark de teste para uma tarefa Spark pesada.
* **k8s-apps:** Diretório contendo o código Terraform para provisionar os recursos do Kubernetes para o ambiente de Big Data:
    * **iac:** Diretório contendo os arquivos de configuração do Terraform.
        * **airflow.tf:** Define os recursos do Kubernetes para o Apache Airflow.
        * **argocd.tf:** Define os recursos do Kubernetes para o ArgoCD (opcional, para gerenciamento de aplicativos).
        * **backend.tf:** Define os recursos do Kubernetes para Terraform.
        * **cluster-autoscaler.tf:** Define os recursos do Kubernetes para o Cluster Autoscaler (opcional, para escalonamento automático do cluster).''
        * **controller.tf:** Define os recursos do Kubernetes para o controlador do aplicativo (pode variar de acordo com a sua aplicação).
        * **eks-variables.tf:** Variáveis específicas para o Amazon EKS (se for o provedor de nuvem escolhido).
        * **grafana.tf:** Define os recursos do Kubernetes para o Grafana (opcional, para monitoramento).
        * **iam-controller.tf:** Define os recursos do Kubernetes para o IAM Controller (gerenciamento de políticas de identidade e acesso).
        * **metrics-server.tf:** Define os recursos do Kubernetes para o Metrics Server (opcional, para coleta de métricas).
        * **policies:** Diretório contendo políticas do Kubernetes.
            * **iam_policy-alb-controller.json:** Exemplo de uma política IAM para o ALB Ingress Controller.
        * **prometheus.tf:** Define os recursos do Kubernetes para o Prometheus (opcional, para monitoramento).
        * **provider.tf:** Define o provedor de nuvem que será utilizado (por exemplo, AWS, GCP).
        * **secrets_manager.tf:** Define os recursos do Kubernetes para o Secrets Manager (opcional, para gerenciamento de segredos).
        * **spark-operator.tf:** Define os recursos do Kubernetes para o Spark Operator.
        * **variables.tf:** Define as variáveis globais usadas pelo código Terraform.
    * **k8s:** Diretório contendo os manifestos do Helm para implantar aplicativos adicionais no cluster Kubernetes.
        * **applications:** Diretório contendo gráficos do Helm para aplicativos.
        * **manifests:** Diretório contendo os manifestos do Kubernetes para aplicativos.
* **k8s-infra:** Diretório contendo o código Terraform para provisionar a infraestrutura do Kubernetes na AWS:
    * **iac:** Diretório contendo os arquivos de configuração do Terraform.
        * **backend.tf:** Define os recursos da infraestrutura do Kubernetes para Terraform.
        * **eks.tf:** Define os recursos da infraestrutura do Kubernetes para o Amazon EKS.
        * **provider.tf:** Define o provedor de nuvem que será utilizado (por exemplo, AWS, GCP).
        * **variables.tf:** Define as variáveis globais usadas pelo código Terraform.
    * **scripts:** Diretório contendo scripts usados para gerenciar a infraestrutura do Kubernetes.
* **k8s-infra-persistente:** Diretório contendo o código Terraform para provisionar a infraestrutura persistente do Kubernetes na AWS, como o RDS do Airflow, por exemplo
