

resource "aws_s3_bucket" "data" {
  bucket        = "${local.prefix}-data"
  acl           = "private"
  force_destroy = true
}


resource "aws_s3_bucket" "s3_scripts" {
  bucket        = "${local.prefix}-scripts"
  acl           = "private"
  force_destroy = true

}

resource "aws_s3_bucket" "output" {
  bucket        = "${local.prefix}-output"
  acl           = "private"
  force_destroy = true

}

resource "aws_s3_bucket" "athena" {
  bucket        = "${local.prefix}-athena"
  acl           = "private"
  force_destroy = true

}




resource "aws_s3_bucket_object" "job1" {
  bucket = aws_s3_bucket.s3_scripts.bucket
  key    = "job.py"
  source = "${path.module}/scripts/${local.job_script}"
  

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("${path.module}/scripts/${local.job_script}")
}




resource "aws_s3_bucket_object" "data_salaries" {
  bucket = aws_s3_bucket.data.bucket
  key    = local.data_script
  source = "${path.module}/data/${local.data_script}"
  

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("${path.module}/data/${local.data_script}")
}


