#Cloudflare provider configuration
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

#Cloudflare authentication
provider "cloudflare" {
  api_token = var.apitoken #enter api token generated from cloudflare here https://developers.cloudflare.com/fundamentals/api/get-started/create-token/ 
}