terraform {
  backend "s3" {
    bucket = "tf-state-bkt-547845"
    key    = "tf-backend"
    region = "ap-south-1"
  }
}
