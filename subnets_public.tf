resource "aws_subnet" "public" {
  count                           = length(var.availability_zones)
  vpc_id                          = aws_vpc.this.id
  cidr_block                      = cidrsubnet(aws_vpc.this.cidr_block, 8, 0 + count.index)
  ipv6_cidr_block                 = var.enable_ipv6 == true ? cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 0 + count.index) : null
  assign_ipv6_address_on_creation = var.enable_ipv6
  availability_zone               = var.availability_zones[count.index]
  tags                            = merge(module.labels.tags, { "Name" = "${module.labels.name}-public" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(module.labels.tags, { "Name" = "${module.labels.name}-public" })
}

resource "aws_route" "public_ipv4" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route" "public_ipv6" {
  count                       = var.enable_ipv6 == true ? length(var.availability_zones) : 0
  route_table_id              = aws_route_table.public.id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}