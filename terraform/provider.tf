provider "aws" {
    alias = "mumbai"
    region = var.aws_region 
}

terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    use_lockfile   = false
    encrypt        = true
  }
}