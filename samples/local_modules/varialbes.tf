variable prefix { 

     type = string 
     default = "euw1-cap"
     description = "resource prefixes"
}


variable "glue_buckets" {
    type = map(string)
    description = "list of buckets glue uses for its operations"
}

# TODO: build in logic for scripts or buckets to be transfered (data script is not always requried)
variable "data_script" {
    type = string
    description = "name of the file within the data_bucket that glue needs to load"
}

variable "job_script" {
    type = string
    description = "The name of the script the glue job should run"
}