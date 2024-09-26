# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_region" "this" {}
data "aws_partition" "this" {}
data "aws_caller_identity" "this" {}
data "aws_availability_zones" "this" {}
