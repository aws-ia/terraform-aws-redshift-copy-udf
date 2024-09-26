# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

module "udf" {
  source  = "../../"
  version = "~> 1.0"

  name        = "redshift-copy-udf"
  memory_size = 128
  timeout     = 5

  vpc_subnet_ids     = null # replace with comma separated values
  security_group_ids = null # replace with comma separated values
}
