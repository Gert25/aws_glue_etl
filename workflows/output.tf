output "user_params" {
   value=<<EOF
   WorkflowName=${var.workflow_name} 
   IAMRole=${aws_iam_role.glue_role.name} 
   InputDataLocation="s3://${aws_s3_bucket.data.bucket}/${aws_s3_bucket_object.data_salaries.id}" 
   DestinationDatabaseName=${aws_glue_catalog_database.blueprint.name } 
   DestinationTableName=${aws_glue_catalog_table.aws_glue_catalog_table.id} 
   OutputDataLocation="s3://${aws_s3_bucket.output.bucket}" 
   NumberOfWorkers=${var.number_of_workders} 
   ScriptLocation="s3://${aws_s3_bucket.s3_scripts.bucket}/${aws_s3_bucket_object.job1.id}"
   BlueprintScriptLocation="s3://${aws_s3_bucket.blueprints.bucket}/${aws_s3_bucket_object.blue_print_zip.id}"
   BlueprintDescription="${var.blue_print_description}"
   EOF
}