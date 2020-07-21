resource "aws_eip" "this" {
  count = length(var.availability_zones)
  vpc   = true
  tags  = module.labels.tags
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = module.labels.tags
}

resource "aws_egress_only_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = module.labels.tags
}

resource "aws_nat_gateway" "this" {
  count         = length(var.availability_zones)
  subnet_id     = aws_subnet.public.*.id[count.index]
  allocation_id = aws_eip.this.*.id[count.index]
  tags          = module.labels.tags
}
