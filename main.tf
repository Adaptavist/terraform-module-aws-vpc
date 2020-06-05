terraform {
  required_version = ">= 0.12.0"
}

module "labels" {
  source    = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=master" //TODO: PIN TO VERSION
  namespace = var.namespace
  stage     = var.stage
  name      = var.name
  tags      = var.tags
}

resource "aws_vpc" "this" {
  cidr_block                       = var.cidr_block
  assign_generated_ipv6_cidr_block = var.enable_ipv6
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  instance_tenancy                 = var.instance_tenancy
  tags                             = module.labels.tags
}

resource "aws_subnet" "public" {
  count                           = length(var.availability_zones)
  vpc_id                          = aws_vpc.this.id
  cidr_block                      = cidrsubnet(aws_vpc.this.cidr_block, 8, 0 + count.index)
  ipv6_cidr_block                 = var.enable_ipv6 ? cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 0 + count.index) : null
  assign_ipv6_address_on_creation = var.enable_ipv6
  availability_zone               = var.availability_zones[count.index]
  tags                            = module.labels.tags
}

resource "aws_subnet" "private" {
  count                           = length(var.availability_zones)
  vpc_id                          = aws_vpc.this.id
  cidr_block                      = cidrsubnet(aws_vpc.this.cidr_block, 4, 2 + count.index)
  ipv6_cidr_block                 = var.enable_ipv6 ? cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 20 + count.index) : null
  assign_ipv6_address_on_creation = var.enable_ipv6
  availability_zone               = var.availability_zones[count.index]
  tags                            = module.labels.tags
}

resource "aws_subnet" "isolated" {
  count                           = length(var.availability_zones)
  vpc_id                          = aws_vpc.this.id
  cidr_block                      = cidrsubnet(aws_vpc.this.cidr_block, 7, 4 + count.index)
  ipv6_cidr_block                 = var.enable_ipv6 ? cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 10 + count.index) : null
  assign_ipv6_address_on_creation = var.enable_ipv6
  availability_zone               = var.availability_zones[count.index]
  tags                            = module.labels.tags
}

// NAT GATEWAY AND ROUTING

resource "aws_eip" "private" {
  count = length(var.availability_zones)
  vpc   = true
  tags  = module.labels.tags
}

resource "aws_nat_gateway" "private" {
  count         = length(var.availability_zones)
  subnet_id     = aws_subnet.public.*.id[count.index]
  allocation_id = aws_eip.private.*.id[count.index]
  tags          = module.labels.tags
}

resource "aws_egress_only_internet_gateway" "private" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.this.id
  tags   = module.labels.tags

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.private.*.id[count.index]
  }

  // IPv6 route only when enabled
  dynamic "route" {
    for_each = var.enable_ipv6 ? [aws_egress_only_internet_gateway.private.id] : []
    content {
      ipv6_cidr_block        = "::/0"
      egress_only_gateway_id = route.value
    }
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.*.id[count.index]
}

// INTERNET GATEWAY AND ROUTING

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.this.id
  tags   = module.labels.tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = module.labels.tags

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public.id
  }

  // IPv6 route only when enabled
  dynamic "route" {
    for_each = var.enable_ipv6 ? [aws_internet_gateway.public.id] : []
    content {
      ipv6_cidr_block        = "::/0"
      egress_only_gateway_id = route.value
    }
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}

// ACL FOR isolated SUBNET

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