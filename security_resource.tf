## instance security and load balancer security

## Security group for instance

resource "aws_security_group" "two-tier-ec2-sg" {
    name = "two-tier-ec2-sg"
    description = "Allow all traffic in the vpc"
    vpc_id = aws_vpc.twotiervpc.id

    depends_on = [
        aws_vpc.twotiervpc
     ]

     ingress  {
        from_port = "0"
        to_port = "0"
        protocol = "-1"

     }

       ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "two-tier-ec2-sg"
  }
}

  # Load balancer security group

  resource "aws_security_group" "two-tier-alb-sg" {
  name        = "two-tier-alb-sg"
  description = "load balancer security group"
  vpc_id      = aws_vpc.twotiervpc.id
  depends_on = [
    aws_vpc.twotiervpc
  ]


  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "two-tier-alb-sg"
  }
}
