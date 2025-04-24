terraform {
  backend "s3" {
    bucket = "tf-backend-11113"
    key    = "tf-backend"
    region = "ap-south-1"
  }
}
