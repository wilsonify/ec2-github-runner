provider "aws" {
  profile = "064592191516"
  region  = "us-east-1"
}

terraform {
  backend "s3" {
    bucket  = "064592191516-terraform-state"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    profile = "064592191516"

  }
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  owners = ["amazon"]
}

resource "aws_key_pair" "github_runner_key" {
  key_name   = "github-runner-key"
  public_key = file("github_runner_key.pub")
}

resource "aws_security_group" "github_runner_sg" {
  name        = "github-runner-sg"
  description = "Security group for GitHub Actions self-hosted runner"
  vpc_id      = "vpc-0827c472"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "github_runner_role" {
  name = "github-runner-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_runner_policy" {
  name        = "github-runner-policy"
  description = "Policy for GitHub Actions runner"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        "Action" : [
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : "ec2:CreateTags",
        "Condition" : {
          "StringEquals" : {
            "ec2:CreateAction" : "RunInstances"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListMultipartUploadParts",
          "s3:GetObjectTagging",
          "s3:HeadObject"
        ],
        "Resource" : [
          "arn:aws:s3:::*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_runner_role_attach" {
  role       = aws_iam_role.github_runner_role.name
  policy_arn = aws_iam_policy.github_runner_policy.arn
}

resource "aws_instance" "github_runner" {
  ami                  = data.aws_ami.latest_amazon_linux.id
  instance_type        = "t3.medium"
  subnet_id            = "subnet-3fa0ce75"
  security_groups      = [aws_security_group.github_runner_sg.id]
  key_name             = aws_key_pair.github_runner_key.key_name
  iam_instance_profile = aws_iam_instance_profile.github_runner_instance_profile.name
  user_data            = file("setup_runner.sh")

  tags = {
    Name = "GitHub Runner"
  }
}

resource "aws_iam_instance_profile" "github_runner_instance_profile" {
  name = "github-runner-instance-profile"
  role = aws_iam_role.github_runner_role.name
}

