output "website_bucket_arn" {
  description = "ARN of the bucket"
  value       = module.static-S3-Website-bucket.bucket-arn
}

output "website_bucket_name" {
  description = "Name (id) of the bucket"
  value       = module.static-S3-Website-bucket.bucket-id
}

output "website_bucket_domain" {
  description = "Domain name of the bucket"
  value       = module.static-S3-Website-bucket.website-domian
}