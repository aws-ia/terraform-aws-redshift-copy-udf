--- # Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
--- # SPDX-License-Identifier: Apache-2.0

-- /*
-- Purpose:
--     This sample function demonstrates how to create/use Lambda UDF(s) in Redshift
-- 2024-09-26: written by eistrati
-- */

CREATE OR REPLACE EXTERNAL FUNCTION f_redshift_copy_udf (s3Url varchar, lineNumber integer)
RETURNS varchar(65534) STABLE
LAMBDA 'redshift-copy-udf' IAM_ROLE ':RedshiftRole';

-- SELECT
--   generate_series(0, 100) AS id,
--   f_redshift_copy_udf('s3://{{bucket_name}}/{{file_name}}.csv', id);
