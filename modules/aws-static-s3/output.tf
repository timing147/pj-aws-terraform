output "s3_bucket_domain" {
  description = "Static Web Hosting bucket domain"
  value       = try(aws_s3_bucket.stone-static-bucket.bucket_regional_domain_name)
}

output "s3_bucket_id" {
  description = "Static Web Hosting bucket id"
  value       = try(aws_s3_bucket.stone-static-bucket.id)
}
