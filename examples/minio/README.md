<!-- BEGIN_TF_DOCS -->
# MinIO Example

This terraform module provides complimentary capabilities to
[COPY command](https://docs.aws.amazon.com/redshift/latest/dg/r_COPY.html)
by enabling data copy from S3 API compliant storage solutions such as
[Cloudian](https://github.com/cloudian/cloudian-s3-operator),
[MinIO](https://github.com/minio/minio), and
[Weka](https://github.com/weka/csi-wekafs) into Amazon Redshift with
AWS Lambda UDF (User Defined Function).

## Architecture Diagram

![Architecture Diagram](../../docs/minio-diagram.png "Architecture Diagram")

## Usage

* Initialize terraform configs and modules

```sh
terraform init
```

* Review the resources to be created by terraform

```sh
terraform plan
```

* Apply the changes reviewed in the previous step

```sh
terraform apply
```

* When you need to clean up resources

```sh
terraform destroy
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 20.0 |
| <a name="module_eks_mng"></a> [eks\_mng](#module\_eks\_mng) | terraform-aws-modules/eks/aws//modules/eks-managed-node-group | ~> 20.0 |
| <a name="module_udf"></a> [udf](#module\_udf) | ../../ | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_iam_policy.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.redshift](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.redshift](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_redshiftserverless_namespace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshiftserverless_namespace) | resource |
| [aws_redshiftserverless_workgroup.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshiftserverless_workgroup) | resource |
| [aws_availability_zones.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr"></a> [cidr](#input\_cidr) | This is the CIDR block for your EKS cluster | `string` | `"10.0.0.0/16"` | no |
| <a name="input_k8s"></a> [k8s](#input\_k8s) | This is the version of your EKS cluster | `string` | `"1.31"` | no |
| <a name="input_name"></a> [name](#input\_name) | This is the name of your EKS cluster | `string` | `"redshift-minio-demo"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | IAM Role ARN for Redshift Permissions |
| <a name="output_iam_role_id"></a> [iam\_role\_id](#output\_iam\_role\_id) | IAM Role ID for Redshift Permissions |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | IAM Role Name for Redshift Permissions |
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | Lambda Function ARN for Redshift UDF |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | Lambda Function Name for Redshift UDF |
| <a name="output_storage_instructions"></a> [storage\_instructions](#output\_storage\_instructions) | Instructions to install the MinIO storage solution |
<!-- END_TF_DOCS -->