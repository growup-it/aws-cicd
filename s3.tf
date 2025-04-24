terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Variables can be customized via a terraform.tfvars file or CLI
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

variable "bucket_name_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
  default     = "my-static-site"
}

# Generate a random suffix to ensure bucket name uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Create the S3 bucket configured for static website hosting
resource "aws_s3_bucket" "static_site" {
  # Dynamically generate the bucket name by combining a prefix and a random suffix.
  bucket = "${var.bucket_name_prefix}-${random_id.bucket_suffix.hex}"

  # Set ACL to public-read. Note: for S3 website hosting and public read,
  # you will also need to attach a bucket policy, which is attached below.
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Name = "Static Website Bucket"
  }
}

# Data source for building the bucket policy document.
data "aws_iam_policy_document" "public_read_policy" {
  statement {
    sid       = "PublicReadGetObject"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      "${aws_s3_bucket.static_site.arn}/*"
    ]
  }
}

# Attach the public read bucket policy
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.static_site.id
  policy = data.aws_iam_policy_document.public_read_policy.json
}

# Output the bucket name dynamically
output "bucket_name" {
  description = "The name of the S3 bucket created for static website hosting."
  value       = aws_s3_bucket.static_site.bucket
}