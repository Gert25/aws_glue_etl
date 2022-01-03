# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

from awsglue.blueprint.workflow import Workflow, Entities
from awsglue.blueprint.job import Job
from awsglue.blueprint.crawler import *
import boto3
from botocore.client import ClientError
import datetime
import os


def generate_layout(user_params, system_params):
    # file_name = "conversion_{0}_{1}.py".format(user_params['DestinationDatabaseName'], user_params['DestinationTableName'])

    # session = boto3.Session(region_name=system_params['region'])
    # glue = session.client('glue')
    # s3_client = session.client('s3')

    workflow_name = user_params['WorkflowName']

    # Create Database if it does not exists
    # try:
    #     glue.create_database(
    #         DatabaseInput={
    #             'Name': user_params['DestinationDatabaseName']
    #         }
    #     )
    #     print("New database is created.")
    # except glue.exceptions.AlreadyExistsException:
    #     print("Existing database is used.")

    # location = {'LocationConstraint': system_params['region']}
    # Creating script bucket
    # the_script_bucket = f"aws-glue-scripts-{system_params['accountId']}-{system_params['region']}"
    # try:
    #     s3_client.head_bucket(Bucket=the_script_bucket)
    #     print("Script bucket already exists: ", the_script_bucket)
    # except ClientError as ce:
    #     print(ce)
    #     print(ce.response['ResponseMetadata'])
    #     print("Creating script bucket: ", the_script_bucket)
    #     if system_params['region'] == "us-east-1":
    #         bucket = s3_client.create_bucket(Bucket=the_script_bucket)
    #     else:
    #         bucket = s3_client.create_bucket(Bucket=the_script_bucket, CreateBucketConfiguration=location)

    # Creating temp bucket
    # the_temp_bucket = f"aws-glue-temporary-{system_params['accountId']}-{system_params['region']}"
    # the_temp_prefix = f"{workflow_name}/"
    # the_temp_location = f"s3://{the_temp_bucket}/{the_temp_prefix}"
    # try:
    #     s3_client.head_bucket(Bucket=the_temp_bucket)
    #     print("Temp bucket already exists: ", the_temp_bucket)
    # except ClientError as ce:
        # print(ce)
        # print(ce.response['ResponseMetadata'])
        # print("Creating temp bucket: ", the_temp_bucket)
        # if system_params['region'] == "us-east-1":
        #     bucket = s3_client.create_bucket(Bucket=the_temp_bucket)
        # else:
        #     bucket = s3_client.create_bucket(Bucket=the_temp_bucket, CreateBucketConfiguration=location)

    # Upload job script to script bucket
    # the_script_key = f"{workflow_name}/{file_name}"
    # the_script_location = f"s3://{the_script_bucket}/{the_script_key}"
    # with open("conversion/conversion.py", "rb") as f:
    #     s3_client.upload_fileobj(f, the_script_bucket, the_script_key)

    # Structure workflow
    jobs = []
    crawlers = []

    # Create tmp Table if it does not exists
    # try:
    #     glue.create_table(
    #         DatabaseName=user_params['DestinationDatabaseName'],
    #         TableInput={
    #             'Name': "source_" + user_params['DestinationTableName'],
    #             'StorageDescriptor': {
    #                 'Location': user_params['InputDataLocation']
    #             },
    #             'Parameters': {
    #                 'groupFiles': 'inPartition',
    #                 'groupSize': '33554432',
    #             }
    #         }
    #     )
    #     print("New table is created.")
    # except glue.exceptions.AlreadyExistsException:
    #     print("Existing table is used.")
    

    command = {
        "Name": "glueetl",
        "ScriptLocation": user_params["ScriptLocation"],
        "PythonVersion": "3"
    }

    output_location =  user_params['OutputDataLocation']
    arguments = {
        # "--TempDir": the_temp_location,
        "--job-bookmark-option": "job-bookmark-enable",
        "--job-language": "python",
        "--enable-continuous-cloudwatch-log": "true",
        "--ENV" : "production",
        "--output_database": user_params['DestinationDatabaseName'],
        "--tmp_table": "source_" + user_params['DestinationTableName'],
        "--output_table": user_params['DestinationTableName'],
        "--OUTPUT_SRC": output_location,
        "--INPUT_SRC" : user_params['InputDataLocation'],
        "--OUTPUT_FORMAT" : "parquet", 
        "--HOME_DIR": "",
        "--SRC_TYPE" : "csv",
        "--CONN_TYPE" : "s3"
    }

    transform_job = Job(
        Name="{}_job".format(workflow_name),
        Command=command,
        Role=user_params['IAMRole'],
        DefaultArguments=arguments,
        WorkerType="G.1X",
        NumberOfWorkers=user_params['NumberOfWorkers'],
        GlueVersion="3.0"
     )

#  Crawlers API : https://docs.aws.amazon.com/glue/latest/dg/aws-glue-api-crawler-crawling.html

# https://docs.aws.amazon.com/glue/latest/dg/aws-glue-api-crawler-crawling.html#aws-glue-api-crawler-crawling-CrawlerTargets
    targets = {
        "S3Targets": [{"Path" : output_location } ]
        # "CatalogTargets": [
        #     {
        #         "DatabaseName": user_params['DestinationDatabaseName'],
        #         "Tables": ["source_" + user_params['DestinationTableName']]
        #     }
        # ]
    }

    crawler = Crawler(
        Name="{}_crawler".format(workflow_name),
        Role=user_params['IAMRole'],
        Targets=targets,
        DatabaseName=user_params['DestinationDatabaseName'],
        Grouping={
            "TableGroupingPolicy": "CombineCompatibleSchemas"
        },
        SchemaChangePolicy={"DeleteBehavior": "LOG"},
        DependsOn={transform_job: "SUCCEEDED"}
    )
 


    
    jobs.append(transform_job)
    crawlers.append(crawler)
    
    workflow = Workflow(Name=workflow_name, Entities=Entities(Jobs=jobs, Crawlers=crawlers))

    return workflow




print(__name__)


def main():
    try:
        USER_PARAMS = {"WorkflowName": os.environ["_WorkflowName"],
               "ScriptLocation": os.environ["_ScriptLocation"],
               "IAMRole": os.environ["_IAMRole"],
               "InputDataLocation": os.environ["_InputDataLocation"],
               "DestinationDatabaseName": os.environ["_DestinationDatabaseName"],
               "DestinationTableName" :  os.environ["_DestinationTableName"],
               "OutputDataLocation": os.environ["_OutputDataLocation"],
               "NumberOfWorkers": int(os.environ["_NumberOfWorkers"])}
        generated = generate_layout(user_params=USER_PARAMS, system_params={})
        gen_dict = generated.validate()
        print(gen_dict)
    except KeyError as key_err:
        print( "No environment variable {} exist".format(key_err))

    
if __name__ == "__main__":
    main()





def generate_schedule(type):
    now = datetime.datetime.utcnow()
    year = now.year
    number_of_month = now.month
    days = now.day
    hours = now.hour
    minutes = now.minute
    days_of_week = now.weekday()

    if type == 'Hourly':
        return generate_cron_expression(minutes, "0/1", "*", "*", "?", "*")
    elif type == 'Daily':
        return generate_cron_expression(minutes, hours, "*", "*", "?", "*")
    elif type == 'Weekly':
        return generate_cron_expression(minutes, hours, "?", "*", days_of_week, "*")
    elif type == 'Monthly':
        return generate_cron_expression(minutes, hours, days, "*", "?", "*")
    else:
        return generate_cron_expression(minutes, hours, days, number_of_month, "?", year)


def generate_cron_expression(minutes, hours, days, number_of_month, days_of_week, year):
    return "cron({0} {1} {2} {3} {4} {5})".format(minutes, hours, days, number_of_month, days_of_week, year)


