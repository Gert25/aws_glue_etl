
# Archives the blueprint documents
data "archive_file" "blueprint" {
  type        = "zip"
  output_path = local.blueprint_output_dir

  source_dir = "${path.module}/blueprint"
}

