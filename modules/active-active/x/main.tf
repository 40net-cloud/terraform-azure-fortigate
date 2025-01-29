
variable "fgt_count" {
    type = number 
    default = 4
}

variable "prefix" {
    type = string 
    default = "jvh23"
}

locals {
  fgt_name_prefix   = "${var.prefix}-fgt"
  vm_list = formatlist("%s-%s", local.fgt_name_prefix, range(1, var.fgt_count + 1))
}

output "vm_list" {
    value = local.vm_list
}