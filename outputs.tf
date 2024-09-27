# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

output "iam_role_arn" {
  description = "IAM Role ARN for Redshift Permissions"
  value       = aws_iam_role.redshift.arn
}

output "iam_role_id" {
  description = "IAM Role ID for Redshift Permissions"
  value       = aws_iam_role.redshift.id
}

output "iam_role_name" {
  description = "IAM Role Name for Redshift Permissions"
  value       = aws_iam_role.redshift.name
}

output "lambda_function_arn" {
  description = "Lambda Function ARN for Redshift UDF"
  value       = module.lambda.lambda_function_arn
}

output "lambda_function_name" {
  description = "Lambda Function Name for Redshift UDF"
  value       = module.lambda.lambda_function_name
}
