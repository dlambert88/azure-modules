variable "create_resource_group" {
  description = ""
  default     = true
}

variable "resource_group_name" {
  description = ""
  default     = "rg-example"
}

variable "location" {
  description = ""
  default     = "East US"
}

variable "virtual_network_name" {
  description = ""
  default     = "vnet-example"
}

variable "virtual_network_address_space" {
  description = ""
  default     = ["10.0.0.0/16"]
}

variable "dns_servers" {
  description = ""
  default     = []
}

variable "subnet" {
  description = ""
  default     = {}
}

variable "tags" {
  description = ""
  type        = map(string)
  default     = {}
}