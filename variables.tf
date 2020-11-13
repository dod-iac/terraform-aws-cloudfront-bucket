variable "aws_cloudfront_origin_access_identity_arn" {
  type        = string
  description = "The ARN of the CloudFront Origin Access Identity (OAI) granted access to read from the bucket."
}

variable "logging_target_bucket" {
  type        = string
  description = "The name of the bucket that will receive the log objects."
}

variable "logging_target_prefix" {
  type        = string
  description = "To specify a key prefix for log objects.  Defaults to \"s3/[name]/\"."
  default     = null
}

variable "name" {
  type        = string
  description = "The name of the AWS S3 Bucket used to host files served by AWS CloudFront."
}

variable "tags" {
  description = "Tags to apply to the AWS S3 Bucket."
  type        = map(string)
  default     = {}
}
