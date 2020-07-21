resource "aws_subnet" "isolated" {
  count                           = length(var.availability_zones)
  vpc_id                          = aws_vpc.this.id
  cidr_block                      = cidrsubnet(aws_vpc.this.cidr_block, 7, 4 + count.index)
  ipv6_cidr_block                 = var.enable_ipv6 == true ? cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 10 + count.index) : null
  assign_ipv6_address_on_creation = var.enable_ipv6
  availability_zone               = var.availability_zones[count.index]
  tags                            = merge(module.labels.tags, { Name = "${module.labels.name}-isolated" })
}

resource "aws_network_acl" "isolated" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.isolated.*.id
  tags       = module.labels.tags

  dynamic "ingress" {
    for_each = aws_subnet.private.*.cidr_block
    content {
      protocol   = -1
      rule_no    = 100 + ingress.key
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 0
      to_port    = 0
    }
  }

  dynamic "ingress" {
    for_each = var.enable_ipv6 ? aws_subnet.private.*.ipv6_cidr_block : []
    content {
      protocol        = -1
      rule_no         = 200 + ingress.key
      action          = "allow"
      ipv6_cidr_block = ingress.value
      from_port       = 0
      to_port         = 0
    }
  }

  dynamic "egress" {
    for_each = aws_subnet.private.*.cidr_block
    content {
      protocol   = -1
      rule_no    = 100 + egress.key
      action     = "allow"
      cidr_block = egress.value
      from_port  = 0
      to_port    = 0
    }
  }

  dynamic "egress" {
    for_each = var.enable_ipv6 ? aws_subnet.private.*.ipv6_cidr_block : []
    content {
      protocol        = -1
      rule_no         = 200 + egress.key
      action          = "allow"
      ipv6_cidr_block = egress.value
      from_port       = 0
      to_port         = 0
    }
  }
}