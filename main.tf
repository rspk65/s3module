provider "aws" {
  region = local.region

  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

locals {
  bucket_name = "s3-bucket-${random_pet.this.id}"
  region      = "ap-south-1"
}


resource "random_pet" "this" {
  length = 2
}


resource "aws_iam_role" "this" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.this.arn]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}",
    ]
  }
}


module "s3_bucket" {
  source = "github.com/terraform-aws-modules/terraform-aws-s3-bucket/"

  bucket = local.bucket_name

  force_destroy       = true
  acceleration_status = "Suspended"
  request_payer       = "BucketOwner"

  tags = {
    Owner = "Anton"
  }

  

  # Bucket policies
  attach_policy                         = true
  policy                                = data.aws_iam_policy_document.bucket_policy.json




}

