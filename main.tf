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

resource "aws_vpc" "new_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Project VPC"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.new_vpc.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "Private Subnet Project VPC"
  }
}

module "module_instance" {
  source       = "./modules/module_instance"
  instance_ami = "ami-0cfd0973db26b893b"
  subnet_id    = aws_subnet.private_subnet.id
}

resource "aws_s3_bucket" "sonarqube_test" {
  bucket = "nt-sonar-test-bucket"

  tags = {
    Name        = "sonar"
  }

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_policy" "mycompliantpolicy" {
  bucket = "nt-sonar-test-bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "mycompliantpolicy"
    Statement = [
      {
        Sid       = "HTTPSOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.sonarqube_test.arn,
          "${aws_s3_bucket.sonarqube_test.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "example-public-access-block" {
  bucket = aws_s3_bucket.sonarqube_test.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
