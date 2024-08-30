from pyspark.sql import SparkSession
from pyspark.sql.functions import col, rand, when

# Create a SparkSession
spark = SparkSession.builder \
    .appName("DataProcessingExample") \
    .getOrCreate()

# Generate synthetic data
num_rows = 1000000
data = spark.range(0, num_rows).withColumn("value", rand())

# Perform heavy data processing
processed_data = data \
    .withColumn("category", when(col("value") < 0.5, "A").otherwise("B")) \
    .withColumn("processed_value", col("value") * 2) \
    .groupBy("category") \
    .agg({"processed_value": "avg"})

# Show the result
processed_data.show()
