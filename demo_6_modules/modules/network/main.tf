resource "aws_vpc" "prod" {
  cidr_block = var.cidr_block

  tags = {
    Name = "Prod-${var.prefix}"
  }
}

resource "aws_internet_gateway" "awesome_igw" {
  vpc_id = aws_vpc.prod.id
}

resource "aws_route_table" "awesome_route_table" {
  vpc_id = aws_vpc.prod.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.awesome_igw.id
  }

  tags = {
    Name = "Prod"
  }
}

resource "aws_subnet" "awesome_subnet" {
  cidr_block = var.cidr_block
  vpc_id = aws_vpc.prod.id
  availability_zone = var.az

  tags = {
    Name = "Public-${var.prefix}"
  }
}

resource "aws_route_table_association" "awesome_rt_accociate" {
  route_table_id = aws_route_table.awesome_route_table.id
  subnet_id = aws_subnet.awesome_subnet.id
}

resource "aws_security_group" "awesome_sg_web_traffic" {
  name = "${var.prefix}-allow_web_traffic"
  description = "Allow Web traffic on port 80"
  vpc_id = aws_vpc.prod.id

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

resource "aws_network_interface" "awesome_network_interface" {
  subnet_id = aws_subnet.awesome_subnet.id
  private_ips = var.private_ips
  security_groups = [aws_security_group.awesome_sg_web_traffic.id]
}

resource "aws_eip" "awesome_eip" {
  depends_on = [aws_internet_gateway.awesome_igw] # Perfect example to the dependency that cannot be resolved by terraform, see documentation
  vpc = true
  network_interface = aws_network_interface.awesome_network_interface.id
  associate_with_private_ip = var.private_ips[0]
}