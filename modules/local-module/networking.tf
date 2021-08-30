data "aws_vpc" "default_vpc" {
  id = var.vpc_id
}

resource "aws_internet_gateway" "main" {
  vpc_id = data.aws_vpc.default_vpc.id

  tags = {
    managed-by = "terraform"
  }
}

resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.default_vpc.id

  tags = {
    managed-by = "terraform"
  }
}

resource "aws_main_route_table_association" "main" {
  vpc_id         = data.aws_vpc.default_vpc.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_subnet" "public-1" {
#  count = length(var.zones)

  vpc_id = data.aws_vpc.default_vpc.id

  cidr_block        = cidrsubnet(data.aws_vpc.default_vpc.cidr_block, 8, 1)
  availability_zone = "${var.aws_region}${element(var.zones, 1)}"

  map_public_ip_on_launch = true

  tags = {
    managed-by = "terraform"
  }
}

resource "aws_subnet" "public-2" {
#  count = length(var.zones)

  vpc_id = data.aws_vpc.default_vpc.id

  cidr_block        = cidrsubnet(data.aws_vpc.default_vpc.cidr_block, 8, 2)
  availability_zone = "${var.aws_region}${element(var.zones, 2)}"

  map_public_ip_on_launch = true

  tags = {
    managed-by = "terraform"
  }
}


resource "aws_subnet" "private" {

  vpc_id = data.aws_vpc.default_vpc.id

  cidr_block        = cidrsubnet(data.aws_vpc.default_vpc.cidr_block, 8, 3)
  availability_zone = "${var.aws_region}${element(var.zones, 1)}"

  map_public_ip_on_launch = false

  tags = {
    managed-by = "terraform"
  }
}

resource "aws_eip" "test-eip" {
  vpc = true
}

resource "aws_nat_gateway" "test-nat" {
  allocation_id = aws_eip.test-eip.id
  subnet_id = aws_subnet.public-1.id
}

resource "aws_route_table" "private" {
  vpc_id                    = var.vpc_id
  route {
    cidr_block              = "0.0.0.0/0"
    nat_gateway_id          = aws_nat_gateway.test-nat.id
  }
}

resource "aws_route_table_association" "private" {
  subnet_id                 = aws_subnet.private.id
  route_table_id            = aws_route_table.private.id
}

resource "aws_route_table_association" "public-1" {
  depends_on = [aws_subnet.public-1]

  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-2" {
  depends_on = [aws_subnet.public-2]

  subnet_id      = aws_subnet.public-2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "internet_sg" {
  vpc_id = data.aws_vpc.default_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.internet_network]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "internet_ssh_sg" {
  vpc_id = data.aws_vpc.default_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.internet_network]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vms_sg" {
  vpc_id = data.aws_vpc.default_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public-1.cidr_block,aws_subnet.public-2.cidr_block]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "internal" {
  vpc_id = data.aws_vpc.default_vpc.id

  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    self      = true
  }
}
