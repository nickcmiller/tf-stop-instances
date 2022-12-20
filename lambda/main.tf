# -- lambda/main.tf --

#Create Lambda function that implements Python code
#This function will shutdown the instances labeled Dev
resource "aws_lambda_function" "lambda_function" {
  #Uses the Python file that is zipped in main.tf
  filename      = var.filename
  function_name = "stop-Dev-instances"
  #Attach IAM role to Lambda
  role          = var.lambda_role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  timeout       = 60
  #Wait until IAM Policy is attached to IAM role before creating
  depends_on    = [var.role_policy_attachment]
}

# Create the daily shutdown schedule
resource "aws_cloudwatch_event_rule" "every_day" {
  name                = "daily"
  schedule_expression = "rate(1 day)"
}

# Allow CloudWatch to invoke stop_dev_lambda Function
resource "aws_lambda_permission" "allow_cloudwatch_to_invoke" {
  function_name = aws_lambda_function.lambda_function.function_name
  statement_id  = "CloudWatchInvoke"
  action        = "lambda:InvokeFunction"
  #Uses the daily CloudWatch shutdown schedule we just created
  source_arn = aws_cloudwatch_event_rule.every_day.arn
  principal  = "events.amazonaws.com"
}

# Set the stop_dev_lambda to perform when the every_day is triggered
resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule       = aws_cloudwatch_event_rule.every_day.name
  arn        = aws_lambda_function.lambda_function.arn
  depends_on = [aws_cloudwatch_event_rule.every_day, aws_lambda_function.lambda_function]
}