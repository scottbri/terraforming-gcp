variable "management_cidr" {
  type        = "string"
  description = "cidr for common infrastructure management subnet"
  default     = "10.0.0.0/26"
}

variable "pas_cidr" {
  type        = "string"
  description = "cidr for pas deployment subnet"
  default     = "192.168.4.0/24"
}

variable "services_cidr" {
  type        = "string"
  description = "cidr for pas services subnet"
  default     = "192.168.8.0/24"
}

variable "pks_cidr" {
  type        = "string"
  description = "cidr for pks cluster subnet"
  default     = "172.20.4.0/24"
}

variable "pks_services_cidr" {
  type        = "string"
  description = "cidr for pks services subnet"
  default     = "172.20.8.0/24"
}

variable "jumpbox" {
  description = "Create a jumpbox."
  default     = true
}

variable "jumpbox_init_script" {
  description = "Path to the script for initiliazing the jumpbox vm."
  default     = "./jumpbox-init.sh"
}
