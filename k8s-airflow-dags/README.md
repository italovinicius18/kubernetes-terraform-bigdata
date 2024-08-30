# k8s-airflow-dags

Repositório focando em armazenas dags, dependencias e a imagem docker utilizada pelo sprak para execução do Airflow.

## Diretórios:

- dags: Pasta dedicada em armazenar as dags
- scripts: Pasta dedicada em armazenar os scripts pyspark para serem executados
- docker: Pasta com o Dockerfile do spark que é executado a partir do gitlab-ci (Para alterar é necessário fazer commit com a mensagem "build-ecr")
    - jars: Pasta com as dependencias do spark