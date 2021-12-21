# https://docs.aws.amazon.com/glue/latest/dg/create-service-policy.html
resource "aws_iam_policy" "glue_policy" {
  policy = data.template_file.glue_policy.rendered
  name   = "${var.prefix}-glue-policy"
}

/*
 Allow Glue and Lakeformation to assume policy
 */
resource "aws_iam_role" "glue_role" {
  name               = "${var.prefix}-glue-role"
  assume_role_policy = file("${path.module}/policies/assume_lakeformation_glue.json")
}

resource "aws_iam_role_policy_attachment" "glue_role_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}




resource "aws_iam_policy" "data_location_policy" {

  for_each = var.glue_buckets
  name  = "${var.prefix}-data_location-policy-${each.key}"
   

  policy = data.template_file.data_location_policy[each.key].rendered
}

resource "aws_iam_role" "glue_lakeformation_role" {
    name = "${var.prefix}-glue_lakeformation_role"
    assume_role_policy = file("${path.module}/policies/assume_lakeformation_glue.json")


}

resource "aws_iam_role_policy_attachment" "data_location_attachment" {
   for_each = var.glue_buckets
   role = aws_iam_role.glue_lakeformation_role.name
   policy_arn = aws_iam_policy.data_location_policy[each.key].arn


}

resource "aws_iam_role_policy_attachment" "glue_policy_attachment" {
  role       = aws_iam_role.glue_lakeformation_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}


########### Dremio #####################

resource "aws_iam_policy" "dremio_policy" {

  name  = "${var.prefix}-dremio-policy"
   

  policy = data.template_file.dremio_policy.rendered
}



resource "aws_iam_role" "dremio_role" {
  name = "dremio-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs.amazonaws.com"
        }
      },
    ]
  })

}


resource "aws_iam_role_policy_attachment" "dremio" {
  role       = aws_iam_role.dremio_role.name
  policy_arn = aws_iam_policy.dremio_policy.arn
}
