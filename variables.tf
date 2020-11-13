// labelling

variable "name" {
  type    = string
  default = "vpc"
}

variable "namespace" {
  type = string
}

variable "stage" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

// vpc

variable "availability_zones" {
  description = "list of AZs your VPC will utilise"
  type        = list(string)
}

variable "cidr_block" {
  description = "Desired CIDR block"
  type        = string
}

variable "map_public_ipv4" {
  description = "Map public IPv4 on creation"
  type        = bool
  default     = false
}

variable "enable_ipv6" {
  description = "enable IPv6 on the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames"
  type        = bool
  default     = true
}

variable "instance_tenancy" {
  type        = string
  description = "EC2 instance tenancy (default, dedicated)"
  default     = "default"
}

// feature flags
variable "enable_public_subnet" {
  type        = bool
  description = "Flag to enable public subnets"
  default     = true
}

variable "enable_private_subnet" {
  type        = bool
  description = "Flag to enable private subnets"
  default     = true
}

variable "enable_isolated_subnet" {
  type        = bool
  description = "Flag to enable isolated subnets"
  default     = true
}