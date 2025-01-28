# The Ultimate guide to creating and using  Terraform modules: Deploying a static Website Using Amazon S3

## Article Outline
1. Introduction
2. Prerequisites
3. What are Terraform Modules?
4. Anatomy of a Terraform Module
5. Creating a Terraform Module (Step-by-Step)
6. Using a Terraform Module
7  Upload static  files to S3.
8. Best Practices for Terraform Modules
9. Conclusion



## 1. Introduction
 Terraform, an open-source tool developed by  HashiCorp and  one of the most popular , if not the most popular IaC tool  is widely used  by Cloud and  DevOps engineers. As compared to other IaC tools, terraform is widely used because it is Platform Agnostic, employs a declarative language (HashiCorp Configuration Language (HCL)) , terraform is also allows for infrastructure to be modularized enabling reusable code and keeping your code DRY(Don't Repeat Yourself). Terrafrom also has an  large community and  ecosystem. 

 As your terraform code becomes more complex, it becames difficlut to manage and that is where Terraform modules comes to the rescue. Modules are the key ingredient to writing reusable,maintainable, and testable Terraform code

In this article, i will take you through how to write reuseable  modules in terraform. if you are ready grap a cap of coffe and lets get started. 

## 2. Prerequisites
Before you get started make sure you have the following:
1. Basic understanding of Terraform.
2. AWS account with AWS CLI installed and configured
3. Terraform Installed  CLI.
    

## 3. What are Terraform Modules?
HashiCorp defines modules as a container for multiple resources that are used together.In simple terms , a Terraform module is a list of terraform configuration files in a single diretory. Terraform module is analogous to a function in general-purpose programming constracts, they have parameters(input variables) and return values (output values). A module can be as simple as a directory with one or more confiuration files.tf files. For example you can define a resuable VPC module which might include subnets, route tables and security groups.  

### Benefits of using modules
Here are some benefits of using Modules in terraform:
1. Code Reusability: Modules makes it easier to reuse configurations written either by yourself, your team members, or other Terraform practitioners.
2. Encapsulation of Configuration: Modules enables you to  encapsulate configurations into distinct logical components which can help prevent unintended changes to your infrastructure as a result of a change in one part of your infrastructure. 
3. Provide consistency and ensure best practices - Modules also help to provide consistency in your configurations
4. Organize configuration - Modules make it easier to navigate, understand, and update your configuration by keeping related parts of your configuration together. 
   
## 4. Anatomy of a Terraform Module
The file structure of a terraform module:
```bash
    module_name/
            ├── LICENSE
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf
            └── README.md
```
1. LICENSE: Contains the license under which your module will be distributed
2. main.tf: This file contains all the main configurations for your module
3. variables.tf: This is where you place all the variable definitions for your module. When your module is used by others, the variables will be configured as arguments in the module block.
4. outputs.tf: The outputs definition for your module is placed in this file. Module outputs are made available to the configuration using the module.
5. README.md: This is a markdown file  that describes how to use your module. This file is not used by terraform but helps people understand how to use your module.


    

## 5. Creating a Terraform Module (Step-by-Step)
In this section of the article we will be creating a terraform module that  creates an  S3 bucket for hosting a static website.

**Step 1. Clone/Create the directory structure**
You can clone this directory  into your prefered location: Below is the  folder structure 
```bash 
terrform-modules/
├──modules/
│     └──static-S3-Website-bucket/
│         ├── main.tf              
│         ├── variables.tf        
│         ├── outputs.tf
│         ├── README.md   
│         ├── www/  
│         │   ├──index.html
│         │   └── error.html
│         └── LICENSE
├── .gitignore     
├── main.tf    
└── outputs.tf   
```
**Step 2. writing the modules variables**
There are only two variables used in this module for simplicity. You can  modify  and add your own variables if you want.
1. s3-bucket-name variable: The name to assign to your S3 bucket. The bucket name should be globally unique
2. tags variable: Defines a tag for your bucket, defualts to Dev if you do not provide.

```hcl
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
1. "aws_s3_bucket" resource: Creates an S3 bucket with the name and tag you provide as input variables
2. "aws_s3_bucket_website_configuration" resource: Configures your S3 bucket for static website hosting
3. "aws_s3_bucket_ownership_controls" resource: Configures  S3 Bucket Ownership Controls
4. "aws_s3_bucket_public_access_block" resource: Enable public access
5. "aws_s3_bucket_acl" resource: Defines S3 access control list (ACLs)
6. "aws_s3_bucket_policy" resource: Configures S3 bucket policy

```hcl
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
The output file  defines three outputs for the S3 bucket module:
1. bucket's ARN
2. website domain
3. bucket id
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
For the README file a dettailed description of how to use the module is proivded. A sample Licence is also provided in the LICENSE file. You can generate your own licencse file using [Choose a License](https://choosealicense.com/) 


## 6 Using a Terraform Module.

**Step 1. Define the module block**
To use the module you need to use the module block in the main.tf file  that is at  the root directory and provide the required input variables. 
The root module also contains the configurations for  terraform and AWS provider. 

module block usage
```hcl
module "static-S3-Website-bucket" {
    source = "./modules/static-S3-Website-bucket"
    s3-bucket-name = "kodecapsule-website-101"

    tags = {
      Environment:"DEV"
    }
}
```

Terraform and AWS provider configurations

```hcl

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}
```

Combined configurations

```hcl

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}


module "static-S3-Website-bucket" {
    source = "./modules/static-S3-Website-bucket"
    s3-bucket-name = "kodecapsule-website-101"

    tags = {
      Environment:"DEV"
    }
}

```


**Step 2. writing the outputs configuration file**


```hcl
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
```

**Step 3. Running the code**
To run the code use the following commands

1. terraform init will initialize the project and download the neccessory provider code
```bash
terraform init
```
terraform plan  to preview the changes that Terraform will make to your infrastructure
```bash
terraform plan
```

The terraform apply command is used to apply the changes defined in your Terraform configuration files
```bash
terraform apply
```


## 7 Upload static  files to S3.
After terraform creates the  infrastructure , you can now upload your static files into the S3 bucket.
The static files for this peoject are found in the www folder. 
You can upload the files using AWS console or AWS CLI.  

**1.Uploading static files using AWS CLI**
```bash
aws s3 cp modules/static-S3-Website-bucket/www/ s3://<YOUR BUCKET NAME>/ --recursive

```
replace <YOUR BUCKET NAME> with the name of your bucket

## 8. Best Practices for Terraform Modules
Here are some best practices to follow when writing and using modules.
1. Always parameterize your modules. 
2. Follow the "DRY" Principle (Don’t Repeat Yourself)
3. Write Documentation for your Modules 
4.Avoid hardcoding sensitive data (e.g., keys, passwords) in your module variables. 

## 9. Conclusion
Well well, we have come to the end of this deep dive into terraform modules. There are other advance topics about terraform modules that are not covered in this tutorial. To learn more about terrafrom modules , visit the official Terraform page,[Terraform page](https://developer.hashicorp.com/terraform/language/modules )  . Don't forget to add your comments , till then keep coding. 

Thanks