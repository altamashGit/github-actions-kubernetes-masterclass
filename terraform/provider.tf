provider "aws" {
    alias = "mumbai"
    region = var.aws_region 
}

terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "us-west-2"
    use_lockfile   = false
    encrypt        = true
  }
}