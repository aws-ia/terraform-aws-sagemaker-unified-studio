# Project Module Variables

variable "domain_identifier" {
  description = "The ID of the Amazon DataZone domain in which this metadata form type is created."
  type        = string

  validation {
    condition     = can(regex("^dzd[-_][a-zA-Z0-9_-]{1,36}$", var.domain_identifier))
    error_message = "Domain ID must be in the format 'dzd_' or 'dzd-' followed by 1-36 alphanumeric characters, underscores, and hyphens."
  }
}

variable "owning_project_identifier" {
  description = "The ID of the Amazon DataZone project that owns this metadata form type."
  type        = string
  // T
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,36}$", var.owning_project_identifier))
    error_message = "Project name must be between 1 and 64 characters."
  }
}


variable "display_name" {
  description = "The display name of the metadata form"
  type        = string
  default     = ""
}

variable "technical_name" {
  description = "This name will be used when working with APIs."
  type        = string
  validation {
    condition     = can(regex("[a-zA-Z0-9_]+", var.technical_name)) # TODO : Refine
    error_message = "Name must contain at least one number or letter, and may not contain special characters other than underscores"
  }
}

variable "description" {
  description = "The description of this Amazon DataZone metadata form type."
  type        = string
  default     = ""
}

variable "fields" {
  description = "fields of the metadata form"
  type = list(object({
    display_name   = optional(string, "")
    technical_name = string
    description    = optional(string, "")
    field_type     = string
    searchable     = optional(bool, false)  // only enable if field_type is string or glossary
    min            = optional(number, null) // only enable if not date
    max            = optional(number, null) // only enable if not date or glossary
    glossary_id    = optional(string, "")   // only enable if field type set to glossary
    requirement    = optional(list(string), [])
  }))

  validation {
    condition = alltrue([
      for param in var.fields : can(regex("[a-zA-Z0-9_]+", param.technical_name)) # TODO : Refine
    ])
    error_message = "Field technical name must contain at least one number or letter, and may not contain special characters other than underscores"
  }
  validation {
    condition = alltrue([
      for param in var.fields : contains(["Timestamp", "String", "Boolean", "Glossary", "Integer", "Long", "Double", "Float"], param.field_type)
    ])
    error_message = "Parameter field_type must be one of: Timestamp, String, Boolean, Glossary, Integer, Long, Double, Float."
  }
  validation {
    condition = alltrue([
      for param in var.fields : alltrue([for req in param.requirement : contains(["ALWAYS", "PUBLISHING", "SUBSCRIPTION"], req)])
    ])
    error_message = "Values inside parameter requirement must be one of: Always, Publishing, Subscription."
  }
  validation {
    condition = alltrue([
      for param in var.fields : length(param.requirement) == 0 || !(anytrue([for req in param.requirement : contains(["ALWAYS"], req)]) && length(param.requirement) > 1)
    ])
    error_message = "Cannot specify ALWAYS if PUBLISHING or SUBSCRIPTION are also specified as requirement"
  }
  validation {
    condition = alltrue([
      for param in var.fields : param.field_type != "Timestamp" || (param.min == null && param.max == null)
    ])
    error_message = "Cannot specify min or max when field type is set to Timestamp"
  }
  validation {
    condition = alltrue([
      for param in var.fields : param.field_type == "Glossary" || param.field_type == "String" || param.searchable == false
    ])
    error_message = "searchable cannot be set to true for a field unless type is Glossary or String"
  }
  validation {
    condition = alltrue([
      for param in var.fields : param.field_type == "Glossary" || param.glossary_id == ""
    ])
    error_message = "glossary_id can only be set if field_type is set to Glossary"
  }
  validation {
    condition = alltrue([
      for param in var.fields : param.field_type != "Glossary" || param.min == null
    ])
    error_message = "Cannot set min when field_type is set to Glossary"
  }
  validation {
    condition = alltrue([
      for param in var.fields : param.min == null || param.max == null || (param.min != null && param.max != null && param.max >= param.min)
    ])
    error_message = "Maximum value must be greater than or equal to minimum value"
  }
}

variable "enabled" {
  type    = bool
  default = false
}
