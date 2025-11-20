output "bucket_name" {
  description = "Navn på S3 bucket"
  value       = aws_s3_bucket.aialpha_results.id
}

output "bucket_arn" {
  description = "ARN for S3 bucket"
  value       = aws_s3_bucket.aialpha_results.arn
}
