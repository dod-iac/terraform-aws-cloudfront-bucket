/**
 * ## Usage
 *
 * Creates an AWS S3 Bucket used to host files served by AWS CloudFront.
 *
 * ```hcl
 * module "cloudfront_bucket" {
 *   source = "dod-iac/cloudfront-bucket/aws"
 *
 *   aws_cloudfront_origin_access_identity_arn = aws_cloudfront_origin_access_identity.main.iam_arn
 *   name = format("app-%s-www-%s-%s", var.application, var.environment, var.region)
 *   logging_target_bucket = var.logs_bucket_name
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 * Pass an aliased provider to the module as `aws`, to change the region the bucket is in.
 *
 * ```hcl
 * module "cloudfront_bucket" {
 *   source = "dod-iac/cloudfront-bucket/aws"
 *
 *   providers = {
 *     aws           = aws.us-east-1
 *   }
 *
 *   aws_cloudfront_origin_access_identity_arn = aws_cloudfront_origin_access_identity.main.iam_arn
 *   name = format("app-%s-www-%s-%s", var.application, var.environment, "us-east-1")
 *   logging_target_bucket = var.logs_bucket_name
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 * ## Terraform Version
 *
 * Terraform 0.13. Pin module version to ~> 2.0.0 . Submit pull-requests to master branch.
 *
 * Terraform 0.12. Pin module version to ~> 1.0.0 . Submit pull-requests to terraform012 branch.
 *
 * Terraform 0.11 is not supported.
 *
 * ## Upgrade Paths
 *
 * ### Upgrading from 1.0.0 to 2.x.x
 *
 * Version 2.x.x removes the `region` variable.  Pass an aliased provider to the module as `aws`, to change the region the bucket is in.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

# The AWS S3 Bucket used to host files served by CloudFront.
resource "aws_s3_bucket" "main" {
  bucket = var.name

  acl = "private"

  versioning {
    enabled    = false
    mfa_delete = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  logging {
    target_bucket = var.logging_target_bucket
    target_prefix = var.logging_target_prefix != null ? var.logging_target_prefix : format("s3/%s/", var.name)
  }

  tags = var.tags
}

# The Public Access Block for the S3 Bucket.
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  # Block new public ACLs and uploading public objects
  block_public_acls = true

  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true

  # Block new public bucket policies
  block_public_policy = true

  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}

# The IAM policy includes s3:ListBucket.
# Without s3:ListBucket, S3 would return a 403 instead of 404 when a file is not found.
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid = "AllowCloudFrontListBucket"
    actions = [
      "s3:ListBucket"
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        var.aws_cloudfront_origin_access_identity_arn
      ]
    }
    resources = [
      aws_s3_bucket.main.arn
    ]
  }
  statement {
    sid = "AllowCloudFrontGetObject"
    actions = [
      "s3:GetObject"
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        var.aws_cloudfront_origin_access_identity_arn
      ]
    }
    resources = [
      format("%s/*", aws_s3_bucket.main.arn)
    ]
  }
  statement {
    sid     = "DenyHTTP"
    actions = ["s3:*"]
    effect  = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      format("%s/*", aws_s3_bucket.main.arn)
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "main" {
  depends_on = [
    aws_s3_bucket_public_access_block.main
  ]
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}
