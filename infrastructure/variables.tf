variable "location" {
  type    = string
  default = "West Europe"
}

variable "environment" {
  type    = string
  default = "dev"
}

locals {
  cluster_name                 = "${var.environment}-ml-cluster"
  resource_group_name_platform = "platform"
}
