variable "aws_account" {
  type        = string
  description = "AWS Account Number"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "recording_s3_bucket_name" {
  type        = string
  description = "Recording S3 Bucket Name"
}