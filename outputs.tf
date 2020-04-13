output "arn" {
  description = "The ARN of the AWS S3 Bucket used to host files served by AWS CloudFront."
  value       = aws_s3_bucket.main.arn
}

output "bucket_regional_domain_name" {
  description = "The bucket regional domain name of the AWS S3 Bucket used to host files served by AWS CloudFront."
  value       = aws_s3_bucket.main.bucket_regional_domain_name
}
