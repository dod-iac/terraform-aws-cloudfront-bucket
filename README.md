## Usage

Creates an AWS S3 Bucket used to host files served by AWS CloudFront.

```hcl
module "cloudfront_bucket" {
  source = "dod-iac/cloudfront-bucket/aws"

  aws_cloudfront_origin_access_identity_arn = aws_cloudfront_origin_access_identity.main.iam_arn
  name = format("app-%s-www-%s-%s", var.application, var.environment, var.region)
  region = var.region
  logging_target_bucket = var.logs_bucket_name
  tags = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}
```

## Terraform Version

Terraform 0.12. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.

Terraform 0.11 is not supported.

## License

This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | >= 2.55.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.55.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_cloudfront\_origin\_access\_identity\_arn | The ARN of the CloudFront Origin Access Identity (OAI) granted access to read from the bucket. | `string` | n/a | yes |
| logging\_target\_bucket | The name of the bucket that will receive the log objects. | `string` | n/a | yes |
| logging\_target\_prefix | To specify a key prefix for log objects.  Defaults to "s3/[name]/". | `string` | `null` | no |
| name | The name of the AWS S3 Bucket used to host files served by AWS CloudFront. | `string` | n/a | yes |
| region | If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee. | `string` | `""` | no |
| tags | Tags to apply to the AWS S3 Bucket. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN of the AWS S3 Bucket used to host files served by AWS CloudFront. |
| bucket\_regional\_domain\_name | The bucket regional domain name of the AWS S3 Bucket used to host files served by AWS CloudFront. |

