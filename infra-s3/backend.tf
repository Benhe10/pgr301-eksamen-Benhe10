# Backend for Terraform state. Kommentert ut for lokal kjøring uten AWS.
# Uncomment and configure when you have an S3 bucket for remote state and a DynamoDB table for locking.
#
# terraform {
#   backend "s3" {
#     bucket = "pgr301-terraform-state"
#     key    = "aialpha/terraform.tfstate"
#     region = var.region
#   }
# }
