# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

output "iam_role_arn" {
  description = "IAM Role ARN for Redshift Permissions"
  value       = module.udf.iam_role_arn
}

output "iam_role_id" {
  description = "IAM Role ID for Redshift Permissions"
  value       = module.udf.iam_role_id
}

output "iam_role_name" {
  description = "IAM Role Name for Redshift Permissions"
  value       = module.udf.iam_role_name
}

output "lambda_function_arn" {
  description = "Lambda Function ARN for Redshift UDF"
  value       = module.udf.lambda_function_arn
}

output "lambda_function_name" {
  description = "Lambda Function Name for Redshift UDF"
  value       = module.udf.lambda_function_name
}

output "storage_instructions" {
  description = "Instructions to install the MinIO storage solution"
  value       = <<INSTRUCTIONS
  # To install open source storage solution on EKS cluster:

  1) Associate OIDC provider
    eksctl utils associate-iam-oidc-provider \
      --cluster=${var.name} \
      --region=${data.aws_region.this.name} \
      --approve

  2) Create Kubernetes SA 
    eksctl create iamserviceaccount \
      --name minio-operator \
      --namespace minio-operator \
      --cluster ${var.name} \
      --attach-policy-arn ${aws_iam_policy.eks.arn} \
      --approve \
      --override-existing-serviceaccounts
  
  3) Install EBS CSI Driver and Kubernetes Operator
    aws eks update-kubeconfig --name ${var.name} --region ${data.aws_region.this.name}
    kubectl apply -k "github.com/miniohq/marketplace/eks/resources"

  4) Install MinIO Tenant
    kubectl apply -k minio-tenant.yaml
  INSTRUCTIONS
}
