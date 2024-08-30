# -------------------
# BEGIN STAGE BUILD
# -------------------

FROM debian:11-slim as stage

# Unir comandos RUN e limpar caches para reduzir camadas e tamanho da imagem
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /jars

# Jars to download into stage build
RUN    curl -LJO https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar \
    && curl -LJO https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.262/aws-java-sdk-bundle-1.12.262.jar \
    && curl -LJO https://repo1.maven.org/maven2/io/delta/delta-spark_2.12/3.2.0/delta-spark_2.12-3.2.0.jar \
    && curl -LJO https://repo1.maven.org/maven2/io/delta/delta-storage/3.2.0/delta-storage-3.2.0.jar \
    && curl -LJO https://repo1.maven.org/maven2/com/sap/cloud/db/jdbc/ngdbc/2.14.10/ngdbc-2.14.10.jar \
    && curl -LJO https://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/9.2.0.jre8/mssql-jdbc-9.2.0.jre8.jar \
    && curl -LJO https://repo1.maven.org/maven2/com/amazon/deequ/deequ/2.0.7-spark-3.5/deequ-2.0.7-spark-3.5.jar

WORKDIR /jmx

RUN curl -LJO https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/1.0.1/jmx_prometheus_javaagent-1.0.1.jar

# -------------------
# END STAGE BUILD
# -------------------

FROM apache/spark:3.5.0

# Jars to copy from stage into spark base image
COPY --from=stage /jars /opt/spark/jars
COPY --from=stage /jmx /prometheus

USER root

# Combinar instalação de pacotes em uma única camada RUN e limpar caches
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
    && pip3 install --upgrade pip setuptools \
    && pip3 install Cython pyspark==3.5.0 \
    && rm -rf /root/.cache \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements.txt and install
COPY requirements.txt .
RUN pip3 install -r requirements.txt && rm requirements.txt

WORKDIR /opt/spark/work-dir

RUN chmod 777 /opt/spark/work-dir

ENTRYPOINT ["/opt/entrypoint.sh"]

ARG spark_uid=185

USER 185
