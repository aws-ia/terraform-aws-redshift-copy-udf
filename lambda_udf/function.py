# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

import boto3, json, sys, os
from urllib import parse

kwargs = {}
if "STORAGE_URL" in os.environ and os.environ["STORAGE_URL"]:
    kwargs["endpoint_url"] = os.environ["STORAGE_URL"]
    kwargs["verify"] = False
if "STORAGE_USER" in os.environ and os.environ["STORAGE_USER"]:
    kwargs["aws_access_key_id"] = os.environ["STORAGE_USER"]
if "STORAGE_PASS" in os.environ and os.environ["STORAGE_PASS"]:
    kwargs["aws_secret_access_key"] = os.environ["STORAGE_PASS"]
if "STORAGE_TOKEN" in os.environ and os.environ["STORAGE_TOKEN"]:
    kwargs["aws_session_token"] = os.environ["STORAGE_TOKEN"]

client = boto3.client('s3', **kwargs)
cached = {}

class MyException(Exception):
    """Raise for my exceptions"""

def handler(event, context):
    print(f"[DEBUG] event: {event}")
    nr_rec = int(event["num_records"]) if "num_records" in event else 1
    result = {"success": False, "num_records": nr_rec}

    try:
        if "arguments" not in event or not event["arguments"]:
            print("[ERROR] event arguments are missing")
            raise MyException("event arguments are missing")

        if not event["arguments"][0]:
            print(f"[ERROR] s3 url is missing")
            raise MyException("s3 url is missing")

        if len(event["arguments"][0]) < 2:
            print(f"[ERROR] line number is missing")
            raise MyException("line number is missing")

        nr_line = int(event["arguments"][0][1])
        url = parse.urlparse(event["arguments"][0][0])
        print(f"[DEBUG] url parse: {url}")

        key = abs(hash(url.netloc + url.path)) % (10 ** 8)
        if key in cached:
            lines = cached[key]
            print(f"[DEBUG] cached lines count: {len(lines)}")
        else:
            obj = client.get_object(Bucket=url.netloc, Key=url.path.lstrip("/"))
            print(f"[DEBUG] s3 object: {obj}")
            content = obj['Body'].read().decode('utf-8')
            lines = content.splitlines()
            cached[key] = lines
            print(f"[DEBUG] uncached lines count: {len(lines)}")

        if nr_line > len(lines):
            print(f"[ERROR] line number out of range: {nr_line} > {len(lines)}")
            raise MyException("line number out of range")

        rec = []
        if nr_line < 0:
            rec.append(str(len(lines)))
        elif lines:
            for line in lines[nr_line:nr_line + nr_rec]:
                rec.append(line)

        if len(rec) != nr_rec:
            print(f"[ERROR] number of records mismatch: {len(rec)} != {nr_rec}")
            raise MyException("number of records mismatch")

        result["success"] = True
        result["results"] = rec

    except MyException as e:
        result["error_msg"] = str(e)
        print(f"[ERROR] {str(e)}")

    except Exception as e:
        result["error_msg"] = str(e)
        print(f"[ERROR] {str(e)}")
        exc_type, exc_obj, exc_tb = sys.exc_info()
        print(f"[ERROR] exc_info: {exc_type}, {exc_tb.tb_lineno}")

    return json.dumps(result)
