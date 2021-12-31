resource "aws_glue_catalog_database" "blueprint" {
  name = "worflow-pnh-testing"
}

output "glue_catalog_blueprint_database" {
    value = aws_glue_catalog_database.blueprint.name 
}