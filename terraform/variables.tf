variable "resource_group" {
  description = "The name of the resource group in which to create our resources"
}

variable "location" {
  description = "The location/region where the resources are created. Changing this forces a new resource to be created."
  default     = "westeurope"
}

variable "prefix" {
  description = "prefix to create resources"
  default     = "foo"
}
