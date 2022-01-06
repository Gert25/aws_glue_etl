
# AWS Glue ETL 

![image](images/AWS.jpg)

# Introduction 

The Module illustrates  simple ETL/ELT orchestration with AWS Glue and terraform. The orchestration of the jobs are controlled by aws glue triggers 

# Pre-requisites 
 
## Terraform docs 
  
Documentation for the module is generate using see installation details on the official site. [terraform docs](https://terraform-docs.io/user-guide/introduction/). 

## Terraform 
 To run the module you will need to install terraform. [See docs](https://learn.hashicorp.com/tutorials/terraform/install-cli)

# Documentation 

Terraform documentation is automated through `terraform-docs` using a markdown format.

To generate terraform docs use the following command 

`terraform-docs -c .terraform-docs.yml markdown table --output-file README.md  --output-mode inject .`

- `-c` specifies the terraform-docs configuration file to run. 
- `markdown table` specifies the format of how the documentation is generated which in this case the format will be tables in markdown language. [more details](https://terraform-docs.io/user-guide/configuration/formatter/)
- `--output-file` specifies where the file output should be written to. In this case it will be `README.md`. [more details](https://terraform-docs.io/user-guide/configuration/output/)
- `--output-mode inject` specifies write mode which is either `inject` (appends to current document) or `replace` (overwrites document)
- `.` is the directory of the module you want to generate documentation for




# Running Locally  
[Running AWS ETL Jobs locally](https://docs.aws.amazon.com/glue/latest/dg/aws-glue-programming-etl-libraries.html)

For this example we run glue within a docker container that has the necessary pre-installed libraries to run glue locally.Also not that python language is used throughout to implement scripting language.

New docker images are released after every Glue update. The following tagging convention is followed with every glue update 

`glue_libs_<glue-version>_image_<image-version>`


In the following example glue version 3 is used 

## Install docker image

1. Pull docker image 
   `docker pull amazon/aws-glue-libs:glue_libs_3.0.0_image_01`


2. Start the container in the background
```
docker run -itd \
-v ${PWD}/scripts:/home/glue_user/workspace/scripts \
-v ${PWD}/data:/home/glue_user/workspace/data \
-v ${PWD}/output:/home/glue_user/workspace/output \
--name glue_v3 amazon/aws-glue-libs:glue_libs_3.0.0_image_01
```

3. execute a bash on the container 

`docker exec -it glue_v3 bash`

4. Run glue jobs within the container
```
/home/glue_user/spark/bin/spark-submit ~/workspace/scripts/job1.py \
--JOB_NAME "local_test" \
--OUTPUT_SRC "output" \
--INPUT_SRC "Salaries.csv" \
--SRC_TYPE "csv" \
--ENV "local" \
--OUTPUT_FORMAT "csv" \
--CONN_TYPE "s3" \
--HOME_DIR "/home/glue_user/workspace"
```
**OR**

4. Start pyspark execution 
`/home/spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8/bin/pyspark`


### Running Jupyter notebook 

Start the container using the following command 

```
docker run -itd -p 8888:8888 -p 4040:4040 \
-v ~/.aws:/root/.aws:ro \
-v ${PWD}/scripts/:/home/jupyter/jupyter_default_dir/scripts \
-v ${PWD}/data/:/home/jupyter/jupyter_default_dir/data \
--name glue_jupyter amazon/aws-glue-libs:glue_libs_3.0.0_image_01 /home/jupyter/jupyter_start.sh
```


Start the notebook in your browser by visiting the address `http://localhost:8888`

port `4040` is required for pyspark UI. 

**NOTE** Ensure you run a pyspark shell within jupyternotebook when working with the glue context

Jupyter notebook home directory 

`/home/jupyter/jupyter_default_dir`

### References 

[building glue pipline localy](https://aws.amazon.com/blogs/big-data/building-an-aws-glue-etl-pipeline-locally-without-an-aws-account/)

[Glue Connection Types](https://docs.aws.amazon.com/glue/latest/dg/aws-glue-programming-etl-connect.html). Note when running Glue localy we specify `s3` as connection type with `POSIX` path argument.  

[glue versions](https://docs.aws.amazon.com/glue/latest/dg/release-notes.html)

[Glue Format Options](https://docs.aws.amazon.com/glue/latest/dg/aws-glue-programming-etl-format.html)



# Running terraform 

 - Install the latest version of the terraform cli. [Docs](https://learn.hashicorp.com/tutorials/terraform/install-cli)

 - To run the example, `cd` into the examples folder  and run  `terraform init` to install all dependencies.

 - Terraform will assumes your AWS default profile sit in your `~/.aws/credentials` file. If you would like to use a different profile to deploy your infrastructure then just a profile property to the `provider.tf` file
    For Example, if you would want to use a profile named `pnh` in your aws credentials file then just add pnh as the profile in the AWS provider within the `provider.tf` file. 
```
     provider "aws" {
        region  = "eu-west-1"
        version = "3.50.0"

        profile = "pnh"
    
}
``` 

- to deploy the infrastructure just run `terraform deploy` 
         



<!-- BEGIN_TF_DOCS -->

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |
## Requirements

No requirements.
## Modules

No modules.

## Example
```

module "etl" {
   source = "git::git@github.com:Gert25/aws_glue_etl.git?ref=v0.0.1"


    prefix = "euw1-cap"
    glue_buckets = { 
      "data" = aws_s3_bucket.data.bucket, 
      "scripts"= aws_s3_bucket.s3_scripts.bucket 
      "output" = aws_s3_bucket.output.bucket 
      }


    data_script = "Salaries.csv"
    job_script =  aws_s3_bucket_object.job1.id
}

```

# Workflow Overview

### Starting a job
The run a simple ETL process a glue job needs to be be invoked. The glue job is triggered on demand by a glue trigger.

### Input
The data required by the job is described by `data` key in the `glue_buckets`. This variable specify where the glue job needs to fetch the data it needs to load in order to transform

### Transformation
Transformation logic is handled by a glue script which is written in python. this script is uploaded to an s3 bucket during compile time. the script should be placed within the `scripts` folder and the file name should be specified by the `data_script` property. The bucket used to store the scripts is specified by `glue_buckets.scripts` property. The object to upload into the bucket should be specified by the `job_script` property. this ensure that terraform loads the script into the s3 bucket during deployment and links it to the glue job.

### Output
The output of the transformation is stored to a s3 bucket. The output bucket is specified by the `glue_buckets.output` property. it accepts a bucket name where the output is stored.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_script"></a> [data\_script](#input\_data\_script) | name of the file within the data\_bucket that glue needs to load | `string` | n/a | yes |
| <a name="input_glue_buckets"></a> [glue\_buckets](#input\_glue\_buckets) | list of buckets glue uses for its operations | `map(string)` | n/a | yes |
| <a name="input_job_script"></a> [job\_script](#input\_job\_script) | The name of the script the glue job should run | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | resource prefixes | `string` | `"euw1-cap"` | no |
## Outputs

No outputs.

<!-- END_TF_DOCS -->


## Reference 

Airflow AWS Cloud: [link](https://programmaticponderings.com/tag/aws-glue/)
