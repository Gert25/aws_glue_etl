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