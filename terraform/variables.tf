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

variable "vm_name" {
  description = "VM name referenced also in storage-related names."
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_D8s_v3"
}

variable "image_publisher" {
  description = "name of the publisher of the image (az vm image list)"
  default     = "OpenLogic"
}

variable "image_offer" {
  description = "the name of the offer (az vm image list)"
  default     = "CentOS"
}

variable "image_sku" {
  description = "image sku to apply (az vm image list)"
  default     = "7.4"
}

variable "image_version" {
  description = "version of the image to apply (az vm image list)"
  default     = "latest"
}

variable "admin_username" {
  description = "administrator user name"
  default     = "hpcadmin"
}

variable "ssh_key_data" {
  description = "administrator ssk_keys"
}
