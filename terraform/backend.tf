terraform {
  backend "s3" {
    bucket = "apon-tf-deploy"
    key    = "terraform/openshift"
    region = "us-east-2"
  }
}
