terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 4.16"
		}
	}
	
	required_version = ">= 1.2.0"
}

provider "aws" {
	region = "eu-central-1"
}

locals {
	ingress_rules = [{
		port = 22
		cidr_blocks = ["213.57.121.34/32"]
		description = "Ingress rules for port SSH"
	},
	{
		port = 80 
		cidr_blocks = ["0.0.0.0/0"]
		description = "Ingress rules for port HTTP"
	},
	{
                port = 443
                cidr_blocks = ["0.0.0.0/0"]
                description = "Ingress rules for port HTTPS"
	}]
}

resource "aws_security_group" "sg-Eaxmple-ec2" {
        name = "dynamic-block-sg"
	description = "Inbound Rules for WebServer"

	dynamic "ingress" {
		for_each = local.ingress_rules

		content {
			from_port = ingress.value.port
			to_port = ingress.value.port
			protocol = "tcp"
			cidr_blocks = ingress.value.cidr_blocks
			description = ingress.value.description
		}
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		name = "AWS security group dynamic block"
	}
	
}

resource "aws_instance" "example_server" {
	ami = "ami-03b3b5f65db7e5c6f"
	instance_type = "t2.micro"
	key_name = "nodes-key"
	vpc_security_group_ids = [aws_security_group.sg-Eaxmple-ec2.id]
	tags = {
		Name = "Example_ec2"
	}
}

