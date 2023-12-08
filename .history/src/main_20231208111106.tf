# main.tf

provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "MyVPC"
  }
}

# Create a subnet
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"  # Replace with your desired availability zone

  tags = {
    Name = "MySubnet"
  }
}

# Create a security group for instances
resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MySecurityGroup"
  }
}

# Launch an EC2 instance
resource "aws_instance" "my_instance" {
  ami             = "ami-0c55b159cbfafe1f0"  # Replace with your desired AMI ID
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.my_subnet.id
  security_group  = [aws_security_group.my_sg.id]

  tags = {
    Name = "MyInstance"
  }
}

# Create an S3 VPC endpoint
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id       = aws_vpc.my_vpc.id
  service_name = "com.amazonaws.us-east-1.s3"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": ["s3:*"],
      "Effect": "Allow",
      "Resource": "*",
      "Principal": "*"
    }
  ]
}
POLICY
}
