# SSH Key pairs for instances
resource "aws_key_pair" "ssh-key" {
  # The name of the key pair
  key_name   = "example_terraform"
  # The public key value obtained from the variable "var.pubkey"
  public_key = var.pubkey
}

# Variables declaration
variable "pubkey" {
  # Description: The public key value for the SSH key pair
  sensitive = true
}

variable "region" {
  # Description: The AWS region where resources will be created
  sensitive = true
}

variable "accesskey" {
  # Description: The AWS access key for authentication
  sensitive = true
}

variable "secretkey" {
  # Description: The AWS secret key for authentication
  sensitive = true
}

variable "personalssh" {
   # Description: The personal SSH key value
   sensitive = true
}
