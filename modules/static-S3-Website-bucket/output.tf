output "bucket-arn" {
    description = "ARN for the S3 bucket static website"
    value = aws_s3_bucket.static-website-bucket.arn
  
}


output "bucket-id" {
    description = "Id of the static S3 bu;cket"
    value = aws_s3_bucket.static-website-bucket.id
  
}

output "website-domian" {
  description = "Domain for the static Website"
  value = aws_s3_bucket_website_configuration.s3-website-config.website_domain
}