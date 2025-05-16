resource "aws_vpc" "twotiervpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"

    tags ={
        name = "maintwoTierVpc"
    }
}


# Public Subnets
resource "aws_subnet" "two-tier-pub-sub-1" {
    vpc_id = aws_vpc.twotiervpc.id
    cidr_block = "10.0.0.0/18"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
    Name = "two-tier-pub-sub-1"
  }

}


# Public Subnets2
resource "aws_subnet" "two-tier-pub-sub-2" {
    vpc_id = aws_vpc.twotiervpc.id
    cidr_block = "10.0.64.0/18"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true


    tags = {
    Name = "two-tier-pub-sub-2"
  }

}

# Private Subnets1

resource "aws_subnet" "two-tier-private-sub-1" {
    vpc_id = aws_vpc.twotiervpc.id
    cidr_block = "10.0.128.0/18"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = false


    tags = {
    Name = "two-tier-pri-sub-1"
  }

}


resource "aws_subnet" "two-tier-private-sub-2" {
    vpc_id = aws_vpc.twotiervpc.id
    cidr_block = "10.0.192.0/18"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = false


    tags = {
    Name = "two-tier-pri-sub-2"
  }

}

# Internet Gateway

resource "aws_internet_gateway" "twoTierGateway" {
    vpc_id = aws_vpc.twotiervpc.id

    tags = {
    Name = "two-tier-igw"
  }
}


## Route Table

resource "aws_route_table" "twotierRoute" {
  vpc_id = aws_vpc.twotiervpc.id

    route  {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.twoTierGateway.id

    }

}


## Route Table Association
resource "aws_route_table_association" "two-tier-route-as-1" {
  subnet_id = aws_subnet.two-tier-pub-sub-1.id
  route_table_id = aws_route_table.twotierRoute.id

}

resource "aws_route_table_association" "two-tier-route-as-2" {
  subnet_id = aws_subnet.two-tier-pub-sub-2.id
  route_table_id = aws_route_table.twotierRoute.id

}


## Application Load balnacer
resource "aws_lb" "twoTierLB" {
  name = "TwoTierALB"
  internal = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.two-tier-alb-sg.id]
  subnets = [aws_subnet.two-tier-pub-sub-1.id, aws_subnet.two-tier-pub-sub-2.id]

  tags = {
    name = "twoTierALB"
  }

}

## create Target group

resource "aws_lb_target_group" "two-tier-loadb_target" {
  name       = "target"
  depends_on = [aws_vpc.twotiervpc]
  port       = "80"
  protocol = "HTTP"
  vpc_id     = aws_vpc.twotiervpc.id

}

}

##listener for ALB

resource "aws_lb_listener" "TwoTierLBListner" {
  load_balancer_arn = aws_lb.twoTierLB.arn
  port = 80
  protocol = "HTTP"

  default_action  {
    type = "forward"
    target_group_arn = aws_lb_target_group.two-tier-loadb_target.arn


  }


}



## creating attachment group for Target group

resource "aws_lb_target_group_attachment" "two-tier-tg-attch-1" {
  target_group_arn = aws_lb_target_group.two-tier-loadb_target.arn
  target_id = aws_instance.two-tier-web-server-1.id
  port = 80

}

resource "aws_lb_target_group_attachment" "two-tier-tg-attch-2" {
  target_group_arn = aws_lb_target_group.two-tier-loadb_target.arn
  target_id = aws_instance.two-tier-web-server-2.id
  port = 80

}
