
resource "aws_s3_bucket" "blueprints" {
  bucket        = "example-pnh-blueprints"
  acl           = "private"
  force_destroy = true
}


resource "aws_s3_bucket_object" "blue_print_zip" {
  bucket = aws_s3_bucket.blueprints.bucket
  key    = "blueprint.zip"
  source = local.blueprint_output_dir
  

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = data.archive_file.blueprint.output_md5
}
