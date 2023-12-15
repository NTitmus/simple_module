terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }


  backend "s3" {
    # This backend configuration is filled in automatically at test time by Terratest. If you wish to run this example
    # manually, uncomment and fill in the config below.

    bucket         = "terraform-book-state-nt2"
    key            = "simple_module/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-book-locks2"
    encrypt        = true
  }
}

module "module_instance" {
  source = "./modules/module_instance"
  instance_ami = "ami-0cfd0973db26b893bzzz"
}