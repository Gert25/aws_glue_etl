
module "etl" {
   source = "../"


    prefix = local.prefix
    glue_buckets = { 
      "data" = aws_s3_bucket.data.bucket, 
      "scripts"= aws_s3_bucket.s3_scripts.bucket 
      "output" = aws_s3_bucket.output.bucket 
      }


    data_script = "Salaries.csv"
    job_script =  aws_s3_bucket_object.job1.id
}

