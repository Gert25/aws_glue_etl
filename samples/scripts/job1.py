import sys 
from awsglue.utils import getResolvedOptions
import pandas as pd 
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.transforms import *
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.types import *
from pyspark.sql import Row
from enum import Enum


class ENV(Enum):
    LOCAL = "local"
    PRODUCTION = "production"

# The AWS Glue getResolvedOptions(args, options) utility function
# gives you access to the arguments that are passed to your
#  script when you run a job

# TODO : user and password for database connections

args = getResolvedOptions(sys.argv, ['ENV','JOB_NAME', 'OUTPUT_SRC', 'INPUT_SRC', 'OUTPUT_FORMAT', 'SRC_TYPE', 'CONN_TYPE'])
glueContext = GlueContext(SparkContext.getOrCreate())


# SET STATE
current_environment = args["ENV"] 
SRC_TYPE = args["SRC_TYPE"] # TODO : Determine if this will still be usefuill 
INPUT_SRC = None
OUTPUT_SRC = None
OUTPUT_FORMAT = args["OUTPUT_FORMAT"] 
CONN_TYPE = args["CONN_TYPE"] # file or s3
if current_environment == ENV.LOCAL.value:
    INPUT_SRC = f'/data/{args["INPUT_SRC"]}'
    OUTPUT_SRC = f'/output/{args["OUTPUT_SRC"]}/csv'
else:
    INPUT_SRC = args["INPUT_SRC"]
    OUTPUT_SRC = args["OUTPUT_SRC"]


# READ INPUT 
glue_df = None 
print(f'ENV: {ENV.LOCAL.value}')

if current_environment == ENV.LOCAL.value:
    # data_source = glueContext.getSource("file", paths=[INPUT_SRC])
    # data_source.setFormat(SRC_TYPE)
    # glue_df = data_source.getFrame()

    # THIS METHOD IS BETTER FOR REEADING CSV DATA
    pd_df =  pd.read_csv(INPUT_SRC) 
    pd_df = pd_df.astype({"Benefits": str})
    spark_df = glueContext.spark_session.createDataFrame(pd_df[['Id', 'JobTitle', 'TotalPay', 'Year', 'Benefits']])  
    glue_df = DynamicFrame.fromDF(spark_df, glueContext, "df")
if current_environment == ENV.PRODUCTION.value:
    salaries_df = glueContext.spark_session.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load(INPUT_SRC)
    glue_df = DynamicFrame.fromDF(salaries_df, glueContext, "df")
    # glue_df = glueContext.create_dynamic_frame_from_options("s3", connection_options={"paths": [INPUT_SRC]}, format=SRC_TYPE)

# elif current_environment == "production":
#     pd_df =  pd.read_csv(INPUT_SRC) 
#     pd_df = pd_df.astype({"Benefits": str})
#     spark_df = glueContext.spark_session.createDataFrame(pd_df[['Id', 'JobTitle', 'TotalPay', 'Year', 'Benefits']])  
#     glue_df = DynamicFrame.fromDF(spark_df, glueContext, "df")

        
print("################### PRINT SCHEMA ########################")
glue_df.printSchema()


# TRANSFORMATION 
dyf_applymapping = ApplyMapping.apply(frame=glue_df , mappings = [
    ("Id", "Long", "id", "String"),
    ("JobTitle", "String", "job_title", "String"),
    ("TotalPay", "Double", "total_pay", "Double"),
    ("Year", "Long", "year", "Long"), 
    ("Benefits", "String", "benefits", "string")
])


def convert_nan(row):
    if row["benefits"] == 'nan':
        row["is_benefits"] = False
    else:
        row["is_benefits"] = True
    return row

mapped_dyf = Map.apply(frame = dyf_applymapping, f= convert_nan)

mapped_dyf.toDF().show()


# Output



if CONN_TYPE in ("s3"):
    partition_keys = ["year", "job_title"]

    glueContext.write_dynamic_frame_from_options(
    frame= mapped_dyf,
    connection_type=CONN_TYPE,
    connection_options={
    "path": OUTPUT_SRC,
    "partitionKeys": partition_keys
    },
    format=OUTPUT_FORMAT,
    transformation_ctx ="datasink")
elif CONN_TYPE in ("mysql", "postgresql" , "redshift", "sqlserver", "oracle"):
    # TODO: Finish database connections options 
    connection_options = {"url": "jdbc-url/database", "user": "username", "password": "password","dbtable": "table-name", "redshiftTmpDir": "s3-tempdir-path"}  
    
    glueContext.write_dynamic_frame_from_options(
    frame= mapped_dyf,
    connection_type=CONN_TYPE,
    connection_options= connection_options,
    format=OUTPUT_FORMAT,
    transformation_ctx ="datasink")


# inputGDF = glueContext.create_dynamic_frame_from_options(connection_type = "s3", connection_options = {"paths": ["s3://pinfare-glue/testing-csv"]}, format = "csv")

# glueContext.write_dynamic_frame.from_options(frame = l_history,
#           connection_type = "s3",
#           connection_options = {"path": "s3://glue-sample-target/output-dir/legislator_history"},
#           format = "parquet")