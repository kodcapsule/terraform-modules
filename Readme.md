# The Ultimate guide to creating and using  Terraform modules: Deploying a static Website Using Amazon S3



## Article Outline
1. Introduction
2. Prerequisites
3. What are Terraform Modules?
4. Anatomy of a Terraform Module
5. Creating a Terraform Module (Step-by-Step)
6. Using a Terraform Module



## 1. Introduction
 Terraform an open-source tool developed by  HashiCorp and  one of the most popular , if not the most popular IaC tool  is widely used  by Cloud engineers  DevOps engineers. As compared to other IaC tools, terraform is widely used because is Platform Agnostic, employs a declarative language (HashiCorp Configuration Language (HCL)) , terraform is also allows for infrastructure to be modularized enabling reusable code and keeping code DRY(Don't Repeat Yourself) code practice. Terrafrom also has an  large community and  ecosystem. 

 As your terraform code becomes more complex, it becames difficlut to manage and that is where Terraform modules comes to the rescue. Modules are the key ingredient to writing reusable,maintainable, and testable Terraform code

In this article, i will take you through how to write reuseable  modules in terraform. if you are ready grap a cap of coffe and lets get started. 

## 2. Prerequisites
Before you get started make sure you have the following:
1. Basic understanding of Terraform.
2. AWS account with AWS CLI installed and configured
3. Installed Terraform CLI.
    

## 3. What are Terraform Modules?
HashiCorp defines modules as a container for multiple resources that are used together.In simple terms , a Terraform module is a list of terraform configuration files in a single diretory. Terraform module is analogous to a function in general-purpose programming constracts, they have parameters(input variables) and return values (output values). A module can be as simple as a directory with one or more .tf files. For example you can define a resuable VPC module which might include subnets, route tables and security groups.  

### Benefits of using modules:
Here are some benefits of using Modules in terraform:
1. Reusability of Configuration: Modules makes it easier reuse configurations written either by yourself, your team members, or other Terraform practitioners.
2. Encapsulation of Configuration: Modules enables you to  encapsulate configurations into distinct logical components which can help prevent unintended changes to your infrastructure as a result of a change in one part of your infrastructure. 
3. Provide consistency and ensure best practices - Modules also help to provide consistency in your configurations
4. Organize configuration - Modules make it easier to navigate, understand, and update your configuration by keeping related parts of your configuration together. 
   
## 4. Anatomy of a Terraform Module
File structure of a terraform module:
```bash
    module_name/
            ├── LICENSE
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf
            └── README.md
```
1. LICENSE: Contain the license under which your module will be distributed
2. main.tf: This file contains all the main configurations for your module
3. variables.tf: This is where you place all the variable definitions for your module. When your module is used by others, the variables will be configured as arguments in the module block
4. outputs.tf: The outputs definition for your module is placed in this file. Module outputs are made available to the configuration using the module
5. README.md: This is a markdown file  that describes how to use your module. This file is not used by terraform but helps people understand how to use your module.


    

## 5. Creating a Terraform Module (Step-by-Step)
In this section of the article we will be creating a terraform module to create S3 bucket for hosting a static website.

**Step 1. Clone/Create the directory structure**
You can clone this directory  into your prefered location: Below is the  folder structure 
```bash 
modules/
├── static-S3-Website-bucket/
│   ├── main.tf              
│   ├── variables.tf        
│   ├── outputs.tf
│   ├── README.md   
│   ├── www/  
│   │   ├──index.html
│   │   └── error.html
│   └── LICENSE
├── .gitignore 
├── main.tf
└── outputs.tf
```
**Step 2. writing the modules varibles**
There are only two variables used in this module for simplicity. you can  modify  and add your own variables if you want.
1. s3-bucket-name variable: The name to assign to your S3 bucket. The bucket should be globally unique
2. tags variable: Defines a tag for your bucket, defualts to Dev if you do not provide.
```
variable "s3-bucket-name" {
    description = "Bucket name for the static website. The name must be globally uique "
    type = string

  
}

variable "tags" {
    description = "Tags to set on the bucket."
    type = map(string)

    default = {
      "env" = "dev"
    }
  }

```
**Step 3. writing the main configuration**
This file creates all the resources that are needed to create a static S3 website. There are 6 resources in all
1."aws_s3_bucket" resource: Creates an S3 bucket with the name and tag you provide as input variables
2."aws_s3_bucket_website_configuration" resource: Configures your S3 bucket for static website hosting
3."aws_s3_bucket_ownership_controls" resource: Configures  S3 Bucket Ownership Control
4."aws_s3_bucket_public_access_block" resource: Enable public access
5."aws_s3_bucket_acl" resource: Defines S3 access control list (ACLs)
6. "aws_s3_bucket_policy" resource: Configures S3 bucket policy

```
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
```

**Step 4. writing the outputs configuration file**
This  defines three outputs for the S3 bucket module:
1.the bucket's ARN
2.the website domain
3. The bucket id
These outputs allow other configurations to reference key attributes of the static S3 website bucket after it's provisioned.

```hcl
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

```


**Step 5. writing the Readme and License files**


## 6 Using a Terraform Module.