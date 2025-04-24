terraform {
  backend "s3" {
    bucket = "tf-backend-1113"
    key    = "tf-backend"
    region = "ap-south-1"
  }
}
