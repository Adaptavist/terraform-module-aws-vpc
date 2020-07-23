resource "aws_subnet" "isolated" {
  count                           = length(var.availability_zones)
  vpc_id                          = aws_vpc.this.id
  cidr_block                      = cidrsubnet(aws_vpc.this.cidr_block, 7, 4 + count.index)
  ipv6_cidr_block                 = var.enable_ipv6 == true ? cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 10 + count.index) : null
  assign_ipv6_address_on_creation = var.enable_ipv6
  availability_zone               = var.availability_zones[count.index]
  tags                            = merge(module.labels.tags, { "Name" = "${module.labels.name}-isolated" })
}

resource "aws_network_acl" "isolated" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.isolated.*.id
  tags       = module.labels.tags
}

// KEEP PUBLIC OUT

resource "aws_network_acl_rule" "isolated_public_ingress" {
  count          = length(aws_subnet.public)
  network_acl_id = aws_network_acl.isolated.id
  rule_action    = "deny"
  rule_number    = 100 + count.index
  protocol       = -1
  cidr_block     = aws_subnet.public[count.index].cidr_block
}

resource "aws_network_acl_rule" "isolated_public_ingress_ip6" {
  count           = length(aws_subnet.private)
  network_acl_id  = aws_network_acl.isolated.id
  rule_action     = "deny"
  rule_number     = 110 + count.index
  protocol        = -1
  ipv6_cidr_block = aws_subnet.private[count.index].ipv6_cidr_block
}

//ALLOW PRIVATE IN

resource "aws_network_acl_rule" "isolated_private_ingress" {
  count          = length(aws_subnet.private)
  network_acl_id = aws_network_acl.isolated.id
  rule_action    = "allow"
  rule_number    = 120 + count.index
  protocol       = -1
  cidr_block     = aws_subnet.private[count.index].cidr_block
}

resource "aws_network_acl_rule" "isolated_private_ingress_ip6" {
  count           = length(aws_subnet.private)
  network_acl_id  = aws_network_acl.isolated.id
  rule_action     = "allow"
  rule_number     = 130 + count.index
  protocol        = -1
  ipv6_cidr_block = aws_subnet.private[count.index].ipv6_cidr_block
}

// ALLOW PRIVATE OUT

resource "aws_network_acl_rule" "isolated_private_egress" {
  count          = length(aws_subnet.private)
  network_acl_id = aws_network_acl.isolated.id
  egress         = true
  rule_action    = "allow"
  rule_number    = 140 + count.index
  protocol       = -1
  cidr_block     = aws_subnet.private[count.index].cidr_block
}

resource "aws_network_acl_rule" "isolated_private_egress_ip6" {
  count           = length(aws_subnet.private)
  network_acl_id  = aws_network_acl.isolated.id
  egress          = true
  rule_action     = "allow"
  rule_number     = 150 + count.index
  protocol        = -1
  ipv6_cidr_block = aws_subnet.private[count.index].ipv6_cidr_block
}