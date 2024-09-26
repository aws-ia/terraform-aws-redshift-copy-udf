# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

variable "name" {
  type        = string
  default     = "redshift-minio-demo"
  description = "This is the name of your EKS cluster"
}

variable "k8s" {
  type        = string
  default     = "1.29"
  description = "This is the version of your EKS cluster"
}

variable "cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "This is the CIDR block for your EKS cluster"
}
