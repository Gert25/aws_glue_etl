resource "aws_glue_catalog_database" "blueprint" {
  name = "worflow-pnh-testing"
}


resource "aws_glue_catalog_table" "aws_glue_catalog_table" {
  name          = "blueprint_catalog"
  database_name = aws_glue_catalog_database.blueprint.name
}