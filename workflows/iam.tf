resource "aws_iam_role" "glue_role" {
  name               = "workflow-glue-role"
  assume_role_policy = data.template_file.assume_glue.rendered

}


resource "aws_iam_policy" "glue_policy" {
  name = "workflow-glue-policy"

  policy = data.template_file.glue_policy.rendered
}


resource "aws_iam_role_policy_attachment" "glue_role_attachment" {
  policy_arn = aws_iam_policy.glue_policy.arn
  role       = aws_iam_role.glue_role.name
}



resource "aws_iam_role" "blueprint_role" {
  name = "workflow-blueprint-role"

  assume_role_policy = data.template_file.assume_glue.rendered

}



resource "aws_iam_policy" "blueprint_policy" {
  name   = "workflow-blueprint-policy"
  policy = data.template_file.blueprint_policy.rendered
}


resource "aws_iam_role_policy_attachment" "blueprint_role_attachment" {
  policy_arn = aws_iam_policy.blueprint_policy.arn
  role       = aws_iam_role.blueprint_role.name
}
