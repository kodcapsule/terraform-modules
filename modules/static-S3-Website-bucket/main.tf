

resource "aws_s3_bucket" "static-website-bucket" {
    bucket = var.s3-bucket-name
    tags = var.tags
  
}


resource "aws_s3_bucket_website_configuration" "s3-website-config" {
    bucket = aws_s3_bucket.static-website-bucket.id
    index_document {
      suffix = "index.html"
    }
    error_document {
      key = "error.html"
    }   
  
}



resource "aws_s3_bucket_acl" "s3-website-bucket-acl" {
    bucket = aws_s3_bucket.static-website-bucket.id
    acl = "public-read"
  
}




resource "aws_s3_bucket_policy" "s3-website-bucket-policy" {
    bucket = aws_s3_bucket.static-website-bucket.id
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.static-website-bucket.arn,
          "${aws_s3_bucket.static-website-bucket.arn}/*",
        ]
      },
    ]
  })
  
}