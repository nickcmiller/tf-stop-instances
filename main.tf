# -- root/main.tf --

#Defines variable I wll use to name the Lambda I'm creating
locals {
  lambda_name = "stop-dev-instances"
}

#Module containing IAM permissions used by Lambda
module "iam" {
  source = "./iam"
}

#Defines a data resource of type "archive_file" named "zip_the_python_code". 
data "archive_file" "zip_the_python_code" {
  type = "zip"
  # Creates a zip archive file by combining the contents of the "python" directory and saving it to the specified output path
  source_dir = "${path.module}/python/"
  # The output path for the zip file is being set to a file 
  # Named after the value of the "lambda_name" local variable in the "python" directory
  output_path = "${path.module}/python/${local.lambda_name}.zip"
}


#Module creating the actual Lambda
module "lambda" {
  source      = "./lambda"
  lambda_name = local.lambda_name
  #The filename of the zip file containing the code for the lambda function
  filename = "${path.module}/python/${local.lambda_name}.zip"
  #The IAM role that the lambda function should assume
  lambda_role_arn        = module.iam.lambda_role_arn
  #The IAM policy attached to that role
  role_policy_attachment = module.iam.role_policy_attachment
}




