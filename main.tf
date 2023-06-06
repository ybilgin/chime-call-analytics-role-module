
# Role
resource "aws_iam_role" "chime_call_analytics_role" {
  name = "ChimeCallAnalyticsRole"
  tags = local.common_tags


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "mediapipelines.chime.amazonaws.com" }
        Action    = "sts:AssumeRole"
        Condition = {
          StringEquals = { "aws:SourceAccount" = var.aws_account }
          ArnLike      = { "aws:SourceARN" = "arn:aws:chime:*:${var.aws_account}:*" }
        }
      }
    ]
  })

}

# Recording Policy
resource "aws_iam_policy" "chime_call_analytics_recording" {
  name        = "ChimeCallAnalyticsRecording"
  path        = "/"
  description = "This policy is used to access Kinsis Video Stream and S3 bcuket required for your call analytics configuration."
  tags        = local.common_tags


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject", "s3:PutObjectAcl"]
        Resource = ["arn:aws:s3:::${var.recording_s3_bucket_name}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObjectTagging"]
        Resource = ["arn:aws:s3:::${var.recording_s3_bucket_name}/*"]
        Condition = {
          "ForAllValues:StringLike" = { "s3:RequestObjectTagKeys" = ["ChimeSDK:*"] }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "kinesisvideo:ListFragments",
          "kinesisvideo:GetMediaForFragmentList"
        ]
        Resource = [
          "arn:aws:kinesisvideo:us-east-1:${var.aws_account}:stream/*"
        ]
        Condition = {
          StringLike = {
            "aws:ResourceTag/AWSServiceName" : "ChimeSDK"
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "kinesisvideo:ListFragments",
          "kinesisvideo:GetMediaForFragmentList"
        ]
        Resource = [
          "arn:aws:kinesisvideo:us-east-1:${var.aws_account}:stream/Chime*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey"
        ]
        Resource = [
          "arn:aws:kms:${var.aws_region}:${var.aws_account}:key/*"
        ]
        Condition = {
          StringLike = {
            "aws:ResourceTag/AWSServiceName" : "ChimeSDK"
          }
        }
      }
    ]
  })
}


# Recording Policy
resource "aws_iam_policy" "chime_call_analytics_kvs" {
  name        = "ChimeCallAnalyticsKVS"
  path        = "/"
  description = "This policy is used to access Kinsis Video Stream and S3 bcuket required for your call analytics configuration."
  tags        = local.common_tags


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "transcribe:StartCallAnalyticsStreamTranscription",
          "transcribe:StartStreamTranscription"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kinesisvideo:GetDataEndpoint",
          "kinesisvideo:GetMedia"
        ]
        Resource = [
          "arn:aws:kinesisvideo:${var.aws_region}:${var.aws_account}:stream/Chime*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kinesisvideo:GetDataEndpoint",
          "kinesisvideo:GetMedia"
        ]
        Resource = [
          "arn:aws:kinesisvideo:${var.aws_region}:${var.aws_account}:stream/*"
        ]
        Condition = {
          StringLike = {
            "aws:ResourceTag/AWSServiceName" : "ChimeSDK"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [
          "arn:aws:kms:${var.aws_region}:${var.aws_account}:key/*"
        ]
        Condition = {
          StringLike = {
            "aws:ResourceTag/AWSServiceName" : "ChimeSDK"
          }
        }
      }
    ]
  })
}



# Role Policy Attachment
resource "aws_iam_role_policy_attachment" "chime_call_analytics_recording_attach" {
  role       = aws_iam_role.chime_call_analytics_role.name
  policy_arn = aws_iam_policy.chime_call_analytics_recording.arn
}

resource "aws_iam_role_policy_attachment" "chime_call_analytics_kvs_attach" {
  role       = aws_iam_role.chime_call_analytics_role.name
  policy_arn = aws_iam_policy.chime_call_analytics_kvs.arn
}