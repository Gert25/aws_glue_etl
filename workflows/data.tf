
# Archives the blueprint documents
data "archive_file" "blueprint" {
  type        = "zip"
  output_path = local.blueprint_output_dir

  source_dir = "${path.module}/blueprint/template"
}





data "template_file" "assume_glue" {
  template = file("${path.module}/policies/assume_glue_policy.json")


}

data "template_file" "glue_policy" {
  template = file("${path.module}/policies/glue_policy.json")


}

data "template_file" "blueprint_policy" {
  template = file("${path.module}/policies/iam_blueprint_policy.json")

  vars = {
    iam_roles = jsonencode([aws_iam_role.glue_role.arn])
  }
}

