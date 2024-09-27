# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_partition" "this" {}

data "aws_secretsmanager_secret" "this" {
  count = local.secret_count
  arn   = var.storage_secret_arn
}

data "aws_secretsmanager_secret_version" "this" {
  count     = local.secret_count
  secret_id = data.aws_secretsmanager_secret.this[0].id
}
