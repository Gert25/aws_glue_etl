

resource "aws_cloudwatch_log_metric_filter" "glue_error" {


    log_group_name = "/aws-glue/jobs/error"
    name           = "glue-errors"
    pattern        = "ERROR"

    metric_transformation {
        default_value = "0"
        dimensions    = {}
        name          = "glue-error"
        namespace     = "Glue"
        unit          = "Count"
        value = 1
    }
}