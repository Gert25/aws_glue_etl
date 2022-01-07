# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0


import boto3
from botocore.client import ClientError
import datetime
import os
from  pathlib import Path
import sys


def generate_layout(user_params, system_params):

    #Note: These packages are imported here since there path depends on the environemnt (local, AWS)
    from  awsglue.blueprint.workflow import Workflow, Entities
    from  awsglue.blueprint.job import Job
    from  awsglue.blueprint.crawler import Crawler
    
    workflow_name = user_params['WorkflowName']
    jobs = []
    crawlers = []

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
        "--HOME_DIR": "NONE",
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

def main():
    try:    
        
        curr_path = Path(os.getcwd())
        parent_path = curr_path.parents[1] # should be blueprint directory
        
        # Check if awsglue exist 
        glue_path = str(parent_path) + '/awsglue'
        assert os.path.isdir(glue_path)
        
        # add the awsglue path as part of the system path
        sys.path.append(str(parent_path))
        # Change append to system path in order to import aws glue modules

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





