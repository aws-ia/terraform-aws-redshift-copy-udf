# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
  iam_policies_arns = [
    "arn:${data.aws_partition.this.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:${data.aws_partition.this.partition}:iam::aws:policy/AmazonS3ReadOnlyAccess",
  ]
  secret_count = try(trimspace(var.storage_secret_arn), "") != "" ? 1 : 0
  env_vars = (
    local.secret_count > 0
    ? jsondecode(data.aws_secretsmanager_secret_version.this[0].secret_string)
    : {
      STORAGE_URL  = var.storage_url
      STORAGE_USER = var.storage_user
      STORAGE_PASS = var.storage_pass
    }
  )
}
