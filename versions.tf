terraform {
  required_version = ">= 0.14.8"

  required_providers {
    kubernetes = ">= 1.10.0, < 3.0.0"
    random = ">=3.2.0"
  }
}
