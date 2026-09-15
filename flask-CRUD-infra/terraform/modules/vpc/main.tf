resource "aws_vpc" "byte_eks_vpc" {
  cidr_block = var.vpc_cidr
  region     = var.eks-region
  tags = {
    Name        = "8bytes-eks-vpc"
    Environment = "Dev"
  }
}


resource "aws_subnet" "public_subnet" {
  count             = length(var.pub_subnet_cidr)
  vpc_id            = aws_vpc.byte_eks_vpc.id
  cidr_block        = var.pub_subnet_cidr[count.index]
  availability_zone = var.azs[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name = "Public-Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.pri_subnet_cidr)
  vpc_id            = aws_vpc.byte_eks_vpc.id
  cidr_block        = var.pri_subnet_cidr[count.index]
  availability_zone = var.azs[count.index]

  map_public_ip_on_launch = false

  tags = {
    "Name" = "Private-Subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.byte_eks_vpc.id

  tags = {
    Name = "internet-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.byte_eks_vpc.id

  tags = {
    Name = "my-public-rt"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.byte_eks_vpc.id

  tags = {
    Name = "my-private-rt"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "my-nw"
  }
}

resource "aws_eip" "my_eip" {
  domain = "vpc"
}

resource "aws_route" "nat_gateway_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my_nat_gateway.id

  depends_on = [aws_eip.my_eip]
}