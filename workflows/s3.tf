
resource "aws_s3_bucket" "blueprints" {
  bucket        = "worflow-pnh-blueprints"
  acl           = "private"
  force_destroy = true
}




resource "aws_s3_bucket" "data" {
  bucket        = "worflow-pnh-data"
  acl           = "private"
  force_destroy = true
}


resource "aws_s3_bucket" "s3_scripts" {
  bucket        = "worflow-pnh-scripts"
  acl           = "private"
  force_destroy = true

}

resource "aws_s3_bucket" "output" {
  bucket        = "worflow-pnh-output"
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

resource "aws_s3_bucket_object" "job1" {
  bucket = aws_s3_bucket.s3_scripts.bucket
  key    = "job.py"
  source = "${path.module}/scripts/job1.py"
  

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("${path.module}/scripts/job1.py")
}




resource "aws_s3_bucket_object" "data_salaries" {
  bucket = aws_s3_bucket.data.bucket
  key    = "Salaries.csv"
  source = "${path.module}/data/Salaries.csv"
  

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("${path.module}/data/Salaries.csv")
}


