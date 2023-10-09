from fastapi import FastAPI
from pyspark.sql import *

app = FastAPI()


@app.get('/')
def index():
    spark = SparkSession.builder \
        .appName("Hello Spark") \
        .master("local[2]") \
        .getOrCreate()

    df = spark.read \
        .format("csv") \
        .option("header", "true") \
        .option("inferSchema", "true") \
        .load('data/annual-enterprise-survey-2021-financial-year-provisional-csv.csv')

    data_itr = df.collect()
    result_list = []
    for row in data_itr:
        result_list.append({
            "name": row["Industry_name_NZSIOC"],
            "age": row["Year"]})

    return result_list
