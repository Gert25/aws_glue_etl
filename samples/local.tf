locals {
  prefix = "euw1-pnh"

  job_script = "job1.py"
  data_script = "Salaries.csv"

glue_buckets = { 
  "data" = aws_s3_bucket.data.bucket, 
  "scripts"= aws_s3_bucket.s3_scripts.bucket 
  "output" = aws_s3_bucket.output.bucket }

 }
