# S3 Bucket Module

This module creates an S3 bucket for hosting a static website

## Usage

```hcl
module "static-S3-Website-bucket" {
    source = "./modules/static-S3-Website-bucket"
    s3-bucket-name = "kodecapsule-website-101"

    tags = {
      Environment:"DEV"
    }
}
```

## Inputs

| Name               | Description                       | Type    | Default | Required |
|--------------------|-----------------------------------|---------|---------|----------|
| `s3-bucket-name`   | The name of the S3 bucket         | string  | n/a     | yes      |
| `tags`             | Enable versioning on the bucket   | map     | Dev     | no       |
-----------------------------------------------------------------------------------------

## Outputs

| Name               | Description                       | 
|--------------------|-----------------------------------|
| `bucket-arn`       | The arn of the S3 bucket          | 
| `website-domian`   | Domain name of the static website | 
| `bucket-id`        | Id of the S3 bucket               |
----------------------------------------------------------