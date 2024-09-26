# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

#######################
# Redshift UDF Module #
#######################
module "udf" {
  source             = "../../"
  memory_size        = 128
  timeout            = 5
  vpc_subnet_ids     = join(",", module.vpc.private_subnets)
  security_group_ids = module.vpc.default_security_group_id
}

##################
# VPC Constructs #
##################
module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "~> 5.0"
  name               = "${var.name}-vpc"
  azs                = local.azs
  cidr               = var.cidr
  private_subnets    = [for k, v in local.azs : cidrsubnet(var.cidr, 4, k)]
  public_subnets     = [for k, v in local.azs : cidrsubnet(var.cidr, 8, k + 48)]
  enable_nat_gateway = true
  single_nat_gateway = true

  default_security_group_name = "${var.name}-sg"
  default_security_group_egress = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "0.0.0.0/0"
  }]
  default_security_group_ingress = [{
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  },{
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "0.0.0.0/0"
  }]
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"
  vpc_id  = module.vpc.vpc_id

  endpoints = {
    dynamodb = {
      service      = "dynamodb"
      service_type = "Gateway"
      route_table_ids = flatten([
        module.vpc.intra_route_table_ids,
        module.vpc.private_route_table_ids,
        module.vpc.public_route_table_ids
      ])
    },
    s3 = {
      service      = "s3"
      service_type = "Gateway"
      route_table_ids = flatten([
        module.vpc.intra_route_table_ids,
        module.vpc.private_route_table_ids,
        module.vpc.public_route_table_ids
      ])
    },
  }
}

##################
# EKS Constructs #
##################
module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "~> 20.0"
  cluster_name                   = var.name
  cluster_version                = var.k8s
  cluster_endpoint_public_access = true

  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets
  control_plane_subnet_ids                 = module.vpc.private_subnets
  enable_cluster_creator_admin_permissions = true

  node_security_group_tags = {
    "kubernetes.io/cluster/${var.name}" = null
  }
}

module "eks_mng" {
  source               = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version              = "~> 20.0"
  name                 = var.name
  cluster_name         = var.name
  cluster_version      = var.k8s
  cluster_service_cidr = module.eks.cluster_service_cidr

  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids            = [module.eks.node_security_group_id, module.vpc.default_security_group_id]
  subnet_ids                        = module.vpc.private_subnets

  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = "SPOT"
  instance_types = ["t3.medium"]
  min_size       = 0
  max_size       = 2
  desired_size   = 1
  disk_size      = 50
}

resource "aws_eks_addon" "this" {
  count        = length(local.addons)
  cluster_name = var.name
  addon_name   = element(local.addons, count.index)
  depends_on   = [module.eks_mng]
}

resource "aws_iam_policy" "eks" {
  name = "${var.name}-eks-policy"
  path = "/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:UpdateNodegroupConfig"
        ],
        "Resource" : [
          "${local.arn_eks_cluster}",
          "${local.arn_eks_nodegroup}"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "eks:CreateNodegroup",
          "eks:TagResource",
          "iam:PassRole",
          "iam:ListAttachedRolePolicies"
        ],
        "Resource" : "${local.arn_eks_cluster}"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:Describe*",
          "ec2:RunInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:CreateTags",
          "iam:GetRole"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "aws-marketplace:MeterUsage",
          "aws-marketplace:ResolveCustomer",
          "aws-marketplace:BatchMeterUsage",
          "aws-marketplace:GetEntitlements",
          "aws-marketplace:RegisterUsage"
        ],
        "Resource" : "*"
      }
    ]
  })
}

#######################
# Redshift Constructs #
#######################
resource "aws_redshiftserverless_namespace" "this" {
  namespace_name        = "${var.name}-namespace"
  iam_roles             = [aws_iam_role.redshift.arn]
  log_exports           = ["connectionlog", "useractivitylog", "userlog"]
  manage_admin_password = true
}

resource "aws_redshiftserverless_workgroup" "this" {
  namespace_name       = aws_redshiftserverless_namespace.this.namespace_name
  workgroup_name       = "${var.name}-workgroup"
  enhanced_vpc_routing = true
  publicly_accessible  = false
  security_group_ids   = [module.vpc.default_security_group_id]
  subnet_ids           = module.vpc.private_subnets

  dynamic "config_parameter" {
    for_each = local.redshift_params
    content {
      parameter_key   = config_parameter.value.parameter_key
      parameter_value = config_parameter.value.parameter_value
    }
  }
}

resource "aws_iam_role" "redshift" {
  name = "${var.name}-redshift-role"
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

resource "aws_iam_role_policy_attachment" "redshift" {
  role       = aws_iam_role.redshift.name
  policy_arn = local.arn_redshift
}
