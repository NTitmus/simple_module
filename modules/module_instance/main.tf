terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_instance" "example" {
  instance_type = "t2.micro"
  ami           = var.instance_ami

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
  }

}
