resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = "${var.prefix}-testing"
}



resource "aws_glue_crawler" "crawler1" {
  database_name = aws_glue_catalog_database.aws_glue_catalog_database.name
  name          = "${var.prefix}-data"
  role          = aws_iam_role.glue_role.arn
   

  s3_target {
    path = "s3://${var.glue_buckets["data"]}/${var.data_script}"
  }
}

resource "aws_glue_job" "job1" {
  depends_on = [aws_iam_role_policy_attachment.glue_role_attachment,aws_iam_role_policy_attachment.glue_policy_attachment]
  name     = "${var.prefix}-job1"
  role_arn = aws_iam_role.glue_role.arn
  glue_version  = "3.0"
  
  default_arguments = {
  "--JOB_NAME" =  "production"
  "--OUTPUT_SRC" =  "s3://${var.glue_buckets["output"]}"
  "--INPUT_SRC"= "s3://${var.glue_buckets["data"]}/${var.data_script}"
  "--SRC_TYPE"= "csv" 
  "--ENV"= "production"
  "--OUTPUT_FORMAT" ="parquet"
  "--CONN_TYPE" =  "s3" 
  "--HOME_DIR" = "None" # required to set this parameter else it will fail during cloud deployment
  }

  command {
    script_location = "s3://${var.glue_buckets["scripts"]}/${var.job_script}"
  }
}

resource "aws_glue_trigger" "example" {
  name = "${var.prefix}-trigger-on-demand-job-1"
  type = "ON_DEMAND"

  actions {
    job_name = aws_glue_job.job1.name
  }
}


resource "aws_glue_crawler" "processed" {
  database_name = aws_glue_catalog_database.aws_glue_catalog_database.name
  name          = "processed"
  role          = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://${var.glue_buckets["output"]}"
  }
}

resource "aws_glue_trigger" "processed" {
  name = "${var.prefix}-trigger-conditional-job-1"
  type = "CONDITIONAL"

   actions {
    crawler_name = aws_glue_crawler.processed.name
  }

  predicate {
    conditions {
      job_name = aws_glue_job.job1.name
      state    = "SUCCEEDED"
    }
  }
}