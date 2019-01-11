# Configure the AWS Provider
provider "aws" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=1.55.0"
}

data "terraform_remote_state" "vpc" {
  backend = "atlas"
  config {
    name = "${var.tfe_org}/${var.vpc_workspace}"
  }
}
resource "aws_security_group" "only_internal_traffic" {
  name        = "only_internal_traffic"
  description = "Allow specific internal traffic"
  vpc_id  = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${var.tags}"
}
