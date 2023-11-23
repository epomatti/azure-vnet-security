terraform {
  backend "local" {
    path = ".workspace/terraform.tfstate"
  }
}
