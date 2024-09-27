# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

##############################
# Lambda Function Constructs #
##############################
module "lambda" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "~> 7.0"
  function_name = format("%s-%s", var.name, random_id.this.hex)
  handler       = "function.handler"
  runtime       = "python3.9"
  memory_size   = var.memory_size
  timeout       = var.timeout
  source_path   = "${path.module}/lambda_udf"

  create_role        = true
  attach_policies    = true
  number_of_policies = length(local.iam_policies_arns)
  policies           = local.iam_policies_arns
  role_path          = "/service-role/"
  policy_path        = "/service-role/"

  environment_variables = {
    for key, value in local.env_vars :
    key => value if try(trimspace(value), "") != ""
  }
  vpc_security_group_ids = (
    try(trimspace(var.security_group_ids), "") != ""
    ? split(",", var.security_group_ids) : null
  )
  vpc_subnet_ids = (
    try(trimspace(var.vpc_subnet_ids), "") != ""
    ? split(",", var.vpc_subnet_ids) : null
  )
}

module "lambda_alias" {
  source        = "terraform-aws-modules/lambda/aws//modules/alias"
  version       = "~> 7.0"
  create        = true
  refresh_alias = true
  name          = var.name
  function_name = module.lambda_function.lambda_function_name
}

resource "random_id" "this" {
  byte_length = 4

  keepers = {
    spf_gid = format("%s-%s-%s", var.name, var.memory_size, var.timeout)
  }
}

####################################
# IAM Role for Redshift Constructs #
####################################
resource "aws_iam_role" "redshift" {
  name = "${var.name}-role"
  path = "/service-role/"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow"
        "Action" : "sts:AssumeRole"
        "Principal" : {
          "Service" : [
            "redshift.amazonaws.com",
            "redshift-serverless.amazonaws.com",
            "sagemaker.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "redshift" {
  name = "${var.name}-policy"
  role = aws_iam_role.redshift.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "lambda:InvokeFunction",
        "Resource" : local.lambda_function_arn
      }
    ]
  })
}
