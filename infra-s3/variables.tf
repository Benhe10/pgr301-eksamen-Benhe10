variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "bucket_name" {
  description = "Navn på S3-bucket for analyseresultater"
  type        = string
  default     = "kandidat-<dittkandidatnr>-data"
}

variable "temporary_prefix" {
  description = "Prefix for midlertidige filer som skal lifecycle-reguleres"
  type        = string
  default     = "midlertidig/"
}

variable "temporary_days_to_delete" {
  description = "Antall dager før filer under midlertidig/ slettes"
  type        = number
  default     = 30
}
