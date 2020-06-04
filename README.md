# AWS VPC

This modules provide a highly available VPC with the following components:

- Public Subnet (Per Availability Zone)
- Private Subnet (Per Availability Zone)
- NAT gateway (Per Availability Zone)
- Isolated Subnet (Per Availability Zone)
- Network ACLs as an additional layer of production
- VPC Flow logs

## Subnet routing

| Subnet   | Internet Ingress | Internet Egress | Public | Private | Isolated |
| -------- | ---------------- | --------------- | ------ | ------- | -------- |
| Public   | ✓                | ✓               | ✓      | ✓       | ✓        |
| Private  |                  | ✓               | ✓      | ✓       | ✓        |
| Isolated |                  |                 | ✓      | ✓       | ✓        |

The table above shows what is routable and from where, this is done from a combination of NAT Gateways, Internet Gatways, Route Tables and network ACLs. [TODO] The subnets can route to each other easily, it is the resposibility of engineers to create suitable Security Groups for their applications, function, databases, etc...

## Variables

| Name                 | Type    | Default | Required | Description                                            |
| -------------------- | ------- | ------- | -------- | ------------------------------------------------------ |
| region               | string  |         | ✓        | Target AWS region                                      |
| cidr_block           | string  |         | ✓        | CIDR block for the entire VPC                          |
| enable_dns_support   | boolean | true    |          | Enable DNS supporting in your VPC                      |
| enable_dns_hostnames | boolean | true    |          | Enable DNS hostnames for EC2 resources                 |
| instance_tenancy     | string  |         |          | Change instance tenance of EC2 resources.              |
| namespace            | string  |         | ✓        | Namespace used for labeling resources                  |
| name                 | string  |         | ✓        | Name of the module / resources                         |
| stage                | string  |         | ✓        | What staga are the resources for? staging, production? |
| tags                 | map     |         | ✓        | Map of tags to be applied to all resources             |

## Outputs

| Name                    | Description                                             |
| ----------------------- | ------------------------------------------------------- |
| vpc_id                  | ID of the VPC                                           |
| vpc_name                | A name generated for the VPC, and added to the Name tag |
| vpc_cidr_block          | VPCs CIDR block                                         |
| vpc_ipv6_cidr_block     | VPCs IPv6 CIDR block                                    |
| public_subnet_ids       | List of public subnet ID's                              |
| public_route_table_ids  | List of public route table ID's                         |
| private_subnet_ids      | List of private subnet ID's                             |
| private_route_table_ids | List of private route table ID's                        |
| isolated_subnet_ids     | List of isolated subnet ID's                            |
