provider "aws" {
  region = var.region
  default_tags {
    tags = merge(local.common_tags, {})
  }
}
