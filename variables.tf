# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

variable "name" {
  type        = string
  default     = "redshift-copy-udf"
  description = "Lambda UDF function name"
}

variable "memory_size" {
  type        = number
  default     = 128
  description = "Lambda UDF memory size"
}

variable "timeout" {
  type        = number
  default     = 300
  description = "Lambda UDF timeout"
}

variable "security_group_ids" {
  type        = string
  default     = null
  description = "Security Group IDs (comma separated values)"
}

variable "vpc_subnet_ids" {
  type        = string
  default     = null
  description = "VPC Subnet IDs (comma separated values)"
}

variable "storage_url" {
  type        = string
  default     = null
  description = "Storage URL to Access S3 API Compliant Storage"
}

variable "storage_user" {
  type        = string
  default     = null
  description = "Storage Username to Access S3 API Compliant Storage"
}

variable "storage_pass" {
  type        = string
  default     = null
  description = "Storage Password to Access S3 API Compliant Storage"
}

variable "storage_token" {
  type        = string
  default     = null
  description = "Storage Token to Access S3 API Compliant Storage (Optional)"
}

variable "storage_secret_arn" {
  type        = string
  default     = null
  description = "Secrets Manager ARN Holding Credentials to Access S3 API Compliant Storage (Optional)"
}
