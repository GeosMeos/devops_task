provider "aws" {
  region                  = var.region
  shared_credentials_file = var.key_path
  profile                 = "default"
}
