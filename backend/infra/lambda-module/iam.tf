resource "aws_iam_policy" "lambda_s3_access_policy" {
  name        = "${var.bucket_name}-s3-access-policy"
  description = "Policy to allow Lambda function to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",           // Bucket level permissions
          "arn:aws:s3:::${var.bucket_name}/*" // Object level permissions
        ]
      }
    ]
  })
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.lambda_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_s3_access_policy.arn
  role       = aws_iam_role.lambda_role.name
}