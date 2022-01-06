resource "aws_glue_catalog_database" "blueprint" {
  name = "worflow-pnh-testing"
}


resource "aws_glue_catalog_table" "aws_glue_catalog_table" {
  name          = "blueprint_catalog"
  database_name = aws_glue_catalog_database.blueprint.name
}



data "template_file" "bootstrap" {
  
  template = file("${path.module}/scripts/bash/bootstrap.sh")

  vars =  { 
      WorkflowName = var.workflow_name
      IAMRole = aws_iam_role.glue_role.name
      InputDataLocation = "s3://${aws_s3_bucket.data.bucket}/${aws_s3_bucket_object.data_salaries.id}" 
      DestinationDatabaseName  = aws_glue_catalog_database.blueprint.name 
      DestinationTableName  = aws_glue_catalog_table.aws_glue_catalog_table.id
      OutputDataLocation = "s3://${aws_s3_bucket.output.bucket}" 
      NumberOfWorkers = var.number_of_workders 
      ScriptLocation = "s3://${aws_s3_bucket.s3_scripts.bucket}/${aws_s3_bucket_object.job1.id}"

  }
  
}



resource "local_file" "boostrap" {
   
   content = data.template_file.bootstrap.rendered
   filename = "${path.module}/bootstrap.sh"

}

resource "null_resource" "bootstrap" {
  depends_on = [
    local_file.boostrap
  ]
   triggers = {
     timestamp = timestamp()
   } 
  provisioner "local-exec" {
    command =  ". ${path.module}/bootstrap.sh"
    interpreter = ["bash", "-c"]
  }
}




data "template_file" "blueprint" {
  
  template = file("${path.module}/scripts/bash/blueprint.sh")
 
  vars =  { 
    profile = var.profile
    region = var.region 
    blueprint_name = "blueprint_${var.workflow_name}"
    blueprint_description = var.blue_print_description
    blueprint_script  = "s3://${aws_s3_bucket.blueprints.bucket}/${aws_s3_bucket_object.blue_print_zip.id}"
  }
  
}
resource "null_resource" "blueprint" {

   triggers = {
    location = "s3://${aws_s3_bucket.blueprints.bucket}/${aws_s3_bucket_object.blue_print_zip.id}"
    file = filemd5("${path.module}/blueprint.zip")
  
   } 
  provisioner "local-exec" {
    command =  data.template_file.blueprint.rendered
    interpreter = ["bash", "-c"]
  }
}



data "template_file" "workflow" {
  
  template = file("${path.module}/scripts/bash/workflow.sh")

  vars =  { 
    profile = var.profile
    region = var.region 
    BlueprintName = "blueprint_${var.workflow_name}"
    WorkflowName = var.workflow_name
    IAMRole = aws_iam_role.glue_role.name
    BlueprintRoleArn = aws_iam_role.blueprint_role.arn
    InputDataLocation = "s3://${aws_s3_bucket.data.bucket}/${aws_s3_bucket_object.data_salaries.id}" 
    DestinationDatabaseName  = aws_glue_catalog_database.blueprint.name 
    DestinationTableName  = aws_glue_catalog_table.aws_glue_catalog_table.id
    OutputDataLocation = "s3://${aws_s3_bucket.output.bucket}" 
    NumberOfWorkers = var.number_of_workders 
    ScriptLocation = "s3://${aws_s3_bucket.s3_scripts.bucket}/${aws_s3_bucket_object.job1.id}"
  }
 
}

resource "null_resource" "workflow" {
   depends_on = [
     null_resource.blueprint
   ]

   triggers = {
     name = var.workflow_name
     template = filemd5("${path.module}/scripts/bash/workflow.sh")
     blueprint = null_resource.bootstrap.id

   } 
  provisioner "local-exec" {
    command =  data.template_file.workflow.rendered
    interpreter = ["bash", "-c"]
  }
}
