resource "aws_subnet" "private" {
  count                           = length(var.availability_zones)
  vpc_id                          = aws_vpc.this.id
  cidr_block                      = cidrsubnet(aws_vpc.this.cidr_block, 4, 2 + count.index)
  ipv6_cidr_block                 = var.enable_ipv6 == true ? cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 20 + count.index) : null
  assign_ipv6_address_on_creation = var.enable_ipv6
  availability_zone               = var.availability_zones[count.index]
  tags                            = merge(module.labels.tags, { Name = "${module.labels.name}-private" })
}

resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.this.id
  tags   = merge(module.labels.tags, { Name = "${module.labels.name}-private-${count.index}" })
}

resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route" "private_ipv4" {
  count                  = length(var.availability_zones)
  route_table_id         = aws_route_table.private[count.index].id
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private_ipv6" {
  count                       = var.enable_ipv6 == true ? length(var.availability_zones) : 0
  route_table_id              = aws_route_table.private[count.index].id
  egress_only_gateway_id      = aws_egress_only_internet_gateway.this.id
  destination_ipv6_cidr_block = "::/0"
}