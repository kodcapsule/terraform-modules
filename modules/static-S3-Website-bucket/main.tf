

resource "aws_s3_bucket" "static-website-bucket" {
    bucket = var.s3-bucket-name
    force_destroy = true
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



resource "aws_s3_bucket_ownership_controls" "bucket-owner" {
  bucket = aws_s3_bucket.static-website-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.public-acl-block]
  
}


resource "aws_s3_bucket_public_access_block" "public-acl-block" {
  bucket = aws_s3_bucket.static-website-bucket.id  

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  
  
}

resource "aws_s3_bucket_acl" "s3-website-bucket-acl" {
    bucket = aws_s3_bucket.static-website-bucket.id
    acl = "public-read"
  
  depends_on = [ aws_s3_bucket_ownership_controls.bucket-owner ]
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
        Action    = "*"
        Resource = [
          aws_s3_bucket.static-website-bucket.arn,
          "${aws_s3_bucket.static-website-bucket.arn}/*",
        ]
      },
    ]
  })
  

  depends_on = [ aws_s3_bucket_public_access_block.public-acl-block ]
}