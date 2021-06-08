variable "location" {
  type    = string
  default = "West Europe"
}

variable "node_pool_vm" {
  type    = string
  default = "Standard_D2_v2"
}

variable "environment" {
  type    = string
  default = "dev"
}

locals {
  cluster_name                 = "${var.environment}-ml-cluster"
  resource_group_name_platform = "platform"
}
