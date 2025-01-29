
variable "fgt_count" {
    type = number 
    default = 4
***REMOVED***

variable "prefix" {
    type = string 
    default = "jvh23"
***REMOVED***

locals {
  fgt_name_prefix   = "${var.prefix***REMOVED***-fgt"
  vm_list = formatlist("%s-%s", local.fgt_name_prefix, range(1, var.fgt_count + 1))
***REMOVED***

output "vm_list" {
    value = local.vm_list
***REMOVED***