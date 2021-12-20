

data "template_file" "glue_policy" {
  template = file("${path.module}/policies/glue_policy.json")
  vars = {

    prefix = var.prefix
  }
}

data "template_file" "data_location_policy" {
  for_each = var.glue_buckets
  template = file("${path.module}/policies/data_location_policy.json")
  vars = {

    s3_bucket_name = each.value
  }
}