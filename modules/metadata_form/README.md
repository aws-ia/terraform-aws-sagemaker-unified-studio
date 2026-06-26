<!-- BEGIN_TF_DOCS -->
# SageMaker Unified Studio Metadata Form Module

This module creates a metadata form type within an Amazon SageMaker Unified Studio domain. Metadata forms define structured fields that can be attached to data assets for governance and cataloging.

## What it does

- Creates a `aws_datazone_form_type` resource with a Smithy model generated from the field definitions
- Supports multiple field types: String, Integer, Long, Double, Float, Boolean, Timestamp, and Glossary
- Handles field-level configuration including display names, descriptions, searchability, min/max constraints, and requirement conditions
- Supports glossary term references for controlled vocabulary fields

## Usage

```hcl
module "metadata_form" {
  source = "./modules/metadata_form"

  domain_identifier         = module.domain.domain_id
  owning_project_identifier = module.project.project_id
  technical_name            = "data_classification"
  display_name              = "Data Classification"
  description               = "Classification metadata for data assets"
  enabled                   = true

  fields = [
    {
      technical_name = "sensitivity_level"
      display_name   = "Sensitivity Level"
      field_type     = "String"
      searchable     = true
      requirement    = ["ALWAYS"]
    },
    {
      technical_name = "retention_days"
      display_name   = "Retention Period (Days)"
      field_type     = "Integer"
      min            = 1
      max            = 3650
    }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.51.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.89.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.51.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_datazone_form_type.form](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datazone_form_type) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_identifier"></a> [domain\_identifier](#input\_domain\_identifier) | The ID of the Amazon DataZone domain in which this metadata form type is created. | `string` | n/a | yes |
| <a name="input_fields"></a> [fields](#input\_fields) | fields of the metadata form | <pre>list(object({<br/>    display_name   = optional(string, "")<br/>    technical_name = string<br/>    description    = optional(string, "")<br/>    field_type     = string<br/>    searchable     = optional(bool, false)  // only enable if field_type is string or glossary<br/>    min            = optional(number, null) // only enable if not date<br/>    max            = optional(number, null) // only enable if not date or glossary<br/>    glossary_id    = optional(string, "")   // only enable if field type set to glossary<br/>    requirement    = optional(list(string), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_owning_project_identifier"></a> [owning\_project\_identifier](#input\_owning\_project\_identifier) | The ID of the Amazon DataZone project that owns this metadata form type. | `string` | n/a | yes |
| <a name="input_technical_name"></a> [technical\_name](#input\_technical\_name) | This name will be used when working with APIs. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | The description of this Amazon DataZone metadata form type. | `string` | `""` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | The display name of the metadata form | `string` | `""` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | n/a | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_smithy"></a> [smithy](#output\_smithy) | n/a |
<!-- END_TF_DOCS -->