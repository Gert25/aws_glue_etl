output "user_params" {
   value=<<EOF
   export _WorkflowName=${var.workflow_name} 
   export _IAMRole=${aws_iam_role.glue_role.name} 
   export _InputDataLocation="s3://${aws_s3_bucket.data.bucket}/${aws_s3_bucket_object.data_salaries.id}" 
   export _DestinationDatabaseName=${aws_glue_catalog_database.blueprint.name } 
   export _DestinationTableName=${aws_glue_catalog_table.aws_glue_catalog_table.id} 
   export _OutputDataLocation="s3://${aws_s3_bucket.output.bucket}" 
   export _NumberOfWorkers=${var.number_of_workders} 
   export _ScriptLocation="s3://${aws_s3_bucket.s3_scripts.bucket}/${aws_s3_bucket_object.job1.id}"
   EOF
}