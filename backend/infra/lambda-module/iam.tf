data "aws_iam_policy_document" "deployer_access" {
  statement {
    actions = [
      "s3:PutObject",
      "iam:ListRoles",
      "lambda:UpdateFunctionCode",
      "lambda:CreateFunction",
      "lambda:UpdateFunctionConfiguration"
    ]

    resources = [
      aws_lambda_function.default.arn
    ]
  }
}

resource "aws_iam_policy" "deployer-access-policy" {
  name        = "allow-deployer-update-lambda"
  description = "Update lambda function"
  policy      = data.aws_iam_policy_document.deployer_access.json
}


resource "aws_iam_group_policy_attachment" "update-lambda-policy-attach" {
  group      = var.aws_iam_group_deployers_name
  policy_arn = aws_iam_policy.deployer-access-policy.arn
}
