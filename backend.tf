terraform {
  backend "s3" {
    bucket = "jessica-iac-projeto-final-iac"
    key    = "projeto-final-iac/terraform.tfstate"
    region = "us-east-1"
  }
}
