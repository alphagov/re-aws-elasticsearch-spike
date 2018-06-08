resource "aws_iam_role" "check_domain_lambda_role" {
  name = "check_domain_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "logging-metrics" {
  role       = "${aws_iam_role.check_domain_lambda_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "check_user_email_domain" {
  filename         = "check_user_email_domain.zip"
  function_name    = "check_user_email_domain"
  role             = "${aws_iam_role.check_domain_lambda_role.arn}"
  handler          = "check_user_email_domain.lambda_handler"
  source_code_hash = "${base64sha256(file("check_user_email_domain.zip"))}"
  runtime          = "python3.6"

  environment {
    variables = {
      DOMAIN = "@digital.cabinet-office.gov.uk"
    }
  }
}
