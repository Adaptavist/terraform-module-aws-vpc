output vpc_id {
  value = aws_vpc.this.id
}

output "vpc_name" {
  value = lookup(aws_vpc.this.tags, "Name")
}

output "vpc_cidr_block" {
  value = aws_vpc.this.cidr_block
}

output "vpc_ipv6_cidr_block" {
  value = aws_vpc.this.ipv6_cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "public_route_table_ids" {
  value = aws_route_table.public.*.id
}

output "public_subnet_cidrs" {
  value = aws_subnet.public.*.cidr_block
}

output "public_subnet_ip6_cidrs" {
  value = aws_subnet.public.*.ipv6_cidr_block
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "private_route_table_ids" {
  value = aws_route_table.private.*.id
}

output "private_subnet_cidrs" {
  value = aws_subnet.private.*.cidr_block
}

output "private_subnet_ip6_cidrs" {
  value = aws_subnet.private.*.ipv6_cidr_block
}

output "isolated_subnet_ids" {
  value = aws_subnet.isolated.*.id
}

output "isolated_subnet_cidrs" {
  value = aws_subnet.isolated.*.cidr_block
}

output "isolated_subnet_ip6_cidrs" {
  value = aws_subnet.isolated.*.ipv6_cidr_block
}

output "tags" {
  value = var.tags
}