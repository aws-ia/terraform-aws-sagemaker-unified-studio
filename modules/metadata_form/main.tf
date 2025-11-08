# SageMaker Unified Studio Metadata Form Module
# This module creates a metadata form within the sagemaker unified studio domain

# Data sources for current context
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Local values
locals {
  smithy = join("",concat(
    [for field in var.fields : field.field_type=="Glossary" ? "@length(max: ${field.max != null ? field.max : 1})\nlist ${replace(upper(field.technical_name), "_", "")}LIST {member: String}\n" : ""],
    [var.display_name == "" ? "" : "@amazon.datazone#displayname(defaultName: \"${var.display_name}\")\n"],
    ["structure ${var.technical_name}\n{\n"],
    [for field in var.fields : join("",
      concat(
        [field.display_name == "" ? "" : "@amazon.datazone#displayname(defaultName: \"${field.display_name}\")\n"],
        [field.description == "" ? "" : "@documentation(\"${field.description}\")\n"],
        [field.searchable ? "@amazon.datazone#searchable\n" : ""],
        // safely handle always true or sometimes true
        [anytrue([for field in field.requirement : field == "ALWAYS"]) ? "@required\n" : ""],
        [(!anytrue([for field in field.requirement : field == "ALWAYS"]) && length(field.requirement) > 0) ? join("",["@amazon.datazone#requiredForCondition(actions:[",join(",", [for field in field.requirement : "\"${field}\""]),"])\n"]) : ""],
        // string has min/max length, numbers have min/max range
        (field.field_type!="Glossary" && (field.min != null || field.max != null)) ? [field.field_type=="String" ? "@length(": "@range(", field.min != null ? "min: ${field.min}" : "", field.min != null && field.max != null ? ", " : "", field.max != null ? "max: ${field.max}" : "", ")\n"] : [""],
        // glossary has different initialization
        (field.field_type=="Glossary") ? ["@amazon.datazone#glossaryterm(\"${field.glossary_id}\")\n","${field.technical_name}: ${replace(upper(field.technical_name), "_", "")}LIST\n"] : ["${field.technical_name}: ${field.field_type}\n"]
    ))],
    ["}"]
  ))
}


resource "aws_datazone_form_type" "form" {
  domain_identifier         = var.domain_identifier
  name                      = var.technical_name
  owning_project_identifier = var.owning_project_identifier
  description               = var.description
  model {
    smithy = local.smithy
  }
  status = var.enabled ? "ENABLED" : "DISABLED"
}

