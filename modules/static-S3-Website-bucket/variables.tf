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