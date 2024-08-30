from airflow import DAG
from datetime import datetime, timedelta
from airflow.providers.cncf.kubernetes.operators.spark_kubernetes import SparkKubernetesOperator
from airflow.providers.cncf.kubernetes.sensors.spark_kubernetes import SparkKubernetesSensor

default_args={
        'owner': 'Ítalo A3',
        'depends_on_past': False,
        'retries': 0,
        "start_date": datetime(2024, 3, 7),
    }

app_name = f"spark-op-{datetime.now().strftime('%Y-%m-%d-%H-%M-%S')}"

with DAG(
    dag_id='teste_spark_simples',
    default_args=default_args,
    description='Teste Spark Operator com SparkPi em Kubernetes',
    schedule_interval="@once",
    catchup=False,
    max_active_runs=1,
    tags=['teste'],
) as dag:
    teste_sync = SparkKubernetesOperator(
        task_id=f'teste_sync',
        namespace='processing',
        application_file='manifests/spark-pesado-v2.yaml',
        # kubernetes_conn_id='kubernetes_default',
        do_xcom_push=False,
        # watch=True
        dag=dag
    )

    # teste_sync_monitor = SparkKubernetesSensor(
    #     task_id=f'teste_sync_monitor',
    #     namespace="processing",
    #     # attach_log=True,
    #     application_name=f"{{{{ ti.xcom_pull(task_ids='teste_sync')['metadata']['name'] }}}}",
    #     # kubernetes_conn_id="kubernetes_default",
    #     dag=dag
    # )    

    teste_sync