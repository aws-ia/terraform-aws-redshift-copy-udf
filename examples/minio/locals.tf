# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
  azs               = slice(data.aws_availability_zones.this.names, 0, 3)
  addons            = ["aws-ebs-csi-driver", "eks-pod-identity-agent", "kube-proxy", "vpc-cni"]
  arn_prefix        = format("arn:%s", data.aws_partition.this.partition)
  arn_suffix        = format("%s:%s", data.aws_region.this.name, data.aws_caller_identity.this.account_id)
  arn_eks_cluster   = format("%s:%s:%s:cluster/%s", local.arn_prefix, "eks", local.arn_suffix, var.name)
  arn_eks_nodegroup = format("%s:%s:%s:nodegroup/%s/*/*", local.arn_prefix, "eks", local.arn_suffix, var.name)
  arn_redshift      = format("%s:iam::aws:policy/AmazonRedshiftAllCommandsFullAccess", local.arn_prefix)

  redshift_params = [
    {
      parameter_key   = "auto_mv"
      parameter_value = "true"
    },
    {
      parameter_key   = "datestyle"
      parameter_value = "ISO, MDY"
    },
    {
      parameter_key   = "enable_case_sensitive_identifier"
      parameter_value = "false"
    },
    {
      parameter_key   = "enable_user_activity_logging"
      parameter_value = "true"
    },
    {
      parameter_key   = "max_query_execution_time"
      parameter_value = "14400"
    },
    {
      parameter_key   = "query_group"
      parameter_value = "default"
    },
    {
      parameter_key   = "require_ssl"
      parameter_value = "false"
    },
    {
      parameter_key   = "search_path"
      parameter_value = "$user, public"
    },
    {
      parameter_key   = "use_fips_ssl"
      parameter_value = "false"
    }
  ]
}
