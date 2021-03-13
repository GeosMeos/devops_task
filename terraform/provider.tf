provider "aws" {
  region                  = var.region
  shared_credentials_file = "/home/aleph/.aws/credentials"
  profile                 = "default"
}
