resource "aws_dynamodb_table" "teleport_state" {
  name           = "${var.teleport_cluster_name}-state"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "HashKey"
  range_key      = "FullPath"

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  # ignore changes to not accidentally destroy table
  lifecycle {
    ignore_changes = all
  }

  attribute {
    name = "HashKey"
    type = "S"
  }

  attribute {
    name = "FullPath"
    type = "S"
  }

  stream_enabled   = "true"
  stream_view_type = "NEW_IMAGE"

  ttl {
    attribute_name = "Expires"
    enabled        = true
  }

}

// DynamoDB table for storing cluster events
resource "aws_dynamodb_table" "teleport_events" {
  name           = "${var.teleport_cluster_name}-events"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "SessionID"
  range_key      = "EventIndex"

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  global_secondary_index {
    name            = "timesearchV2"
    hash_key        = "CreatedAtDate"
    range_key       = "CreatedAt"
    write_capacity  = 10
    read_capacity   = 10
    projection_type = "ALL"
  }

  # ignore changes to not accidentally destroy table
  lifecycle {
    ignore_changes = all
  }

  attribute {
    name = "SessionID"
    type = "S"
  }

  attribute {
    name = "EventIndex"
    type = "N"
  }

  attribute {
    name = "CreatedAtDate"
    type = "S"
  }

  attribute {
    name = "CreatedAt"
    type = "N"
  }

  ttl {
    attribute_name = "Expires"
    enabled        = true
  }

}
# ---------------------------------------------------------------------------- #
# IAM
# ---------------------------------------------------------------------------- #
resource "aws_iam_role_policy_attachment" "teleport_backend" {
  role       = aws_iam_role.console_access.name
  policy_arn = aws_iam_policy.teleport_backend.arn
}
resource "aws_iam_policy" "teleport_backend" {
  name_prefix = var.teleport_cluster_name
  path        = "/"
  description = "Grants Teleport Access to Backend DynamodbTable"


  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ClusterStateStorage",
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchWriteItem",
                "dynamodb:UpdateTimeToLive",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:DescribeStream",
                "dynamodb:UpdateItem",
                "dynamodb:DescribeTimeToLive",
                "dynamodb:DescribeTable",
                "dynamodb:GetShardIterator",
                "dynamodb:GetItem",
                "dynamodb:ConditionCheckItem",
                "dynamodb:UpdateTable",
                "dynamodb:GetRecords",
                "dynamodb:UpdateContinuousBackups"
            ],
            "Resource": [
                "${aws_dynamodb_table.teleport_state.arn}",
                "${aws_dynamodb_table.teleport_state.arn}/stream/*"
            ]
        },
        {
            "Sid": "ClusterEventsStorage",
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchWriteItem",
                "dynamodb:UpdateTimeToLive",
                "dynamodb:PutItem",
                "dynamodb:DescribeTable",
                "dynamodb:DeleteItem",
                "dynamodb:GetItem",
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:UpdateItem",
                "dynamodb:DescribeTimeToLive",
                "dynamodb:UpdateTable",
                "dynamodb:UpdateContinuousBackups"
            ],
            "Resource": [
                "${aws_dynamodb_table.teleport_events.arn}",
                "${aws_dynamodb_table.teleport_events.arn}/index/*"
            ]
        }
    ]
}
EOF
}
# ---------------------------------------------------------------------------- #
# S3
# ---------------------------------------------------------------------------- #
resource "aws_s3_bucket" "teleport_sessions" {
  bucket        = "${var.teleport_cluster_name}-sessions-bucket"
  force_destroy = true

  # ignore changes to not accidentally destroy bucket
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_s3_bucket_acl" "teleport_sessions" {
  depends_on = [aws_s3_bucket_ownership_controls.teleport_sessions]
  bucket     = aws_s3_bucket.teleport_sessions.bucket
  acl        = "private"
}

resource "aws_s3_bucket_ownership_controls" "teleport_sessions" {
  bucket = aws_s3_bucket.teleport_sessions.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "teleport_sessions" {
  bucket = aws_s3_bucket.teleport_sessions.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "teleport_sessions" {
  bucket = aws_s3_bucket.teleport_sessions.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "teleport_sessions" {
  bucket = aws_s3_bucket.teleport_sessions.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# ---------------------------------------------------------------------------- #
# S3 IAM
# ---------------------------------------------------------------------------- #
resource "aws_iam_role_policy_attachment" "teleport_sessions" {
  role       = aws_iam_role.console_access.name
  policy_arn = aws_iam_policy.teleport_sessions.arn
}
resource "aws_iam_policy" "teleport_sessions" {
  name_prefix = var.teleport_cluster_name
  path        = "/"
  description = "Grants Teleport Access to S3 Bucket for Sessions"


  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "BucketActions",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucketVersions",
                "s3:ListBucketMultipartUploads",
                "s3:ListBucket",
                "s3:GetEncryptionConfiguration",
                "s3:GetBucketVersioning"
            ],
            "Resource": "${aws_s3_bucket.teleport_sessions.arn}"
        },
        {
            "Sid": "ObjectActions",
            "Effect": "Allow",
            "Action": [
                "s3:GetObjectVersion",
                "s3:GetObjectRetention",
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListMultipartUploadParts",
                "s3:AbortMultipartUpload"
            ],
            "Resource": "${aws_s3_bucket.teleport_sessions.arn}/*"
        }
    ]
}
EOF
}