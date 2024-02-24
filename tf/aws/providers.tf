# Configure the AWS provider in Terraform
provider "aws" {

  # Set the AWS region using the value specified in the "var.region" variable
  region     = var.region

  # Set the AWS access key using the value specified in the "var.accesskey" variable
  access_key = var.accesskey

  # Set the AWS secret key using the value specified in the "var.secretkey" variable
  secret_key = var.secretkey
}
