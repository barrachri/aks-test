variable "location" {
  type    = string
}

variable "node_pool_vm" {
  type    = string
  default = "Standard_D2_v2"
}

variable "environment" {
  type    = string
}

variable "cluster_name" {
  type    = string
}

variable "resource_group_name" {
  type    = string
}

variable "vnet_subnet_id" {
  type    = string
}
