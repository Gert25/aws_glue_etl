variable workflow_name  { 
      type = string 
      description = "name of the workflow"
      default = "workflow1"
}

variable number_of_workders { 
     type = number 
     description = "number of glue workers"
     default = 2
}

variable "blue_print_description" {
   type = string 
   description = "AWS glue Blueprint description"
   default = "Testing blue script"
}


variable "region" {
   type = string 
   description = "AWS region to deploy resources"
   default = "eu-west-1"
}



variable "profile" {
   type = string 
   description = "AWS profile to use for deploying infrastructure"
   default = "default"
}