variable "private_key_path" {
  type    = string
  default = "/home/user/.ssh/id_ed25519"
}

variable "public_key" {
  type    = string
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK71ymSBL1kxVRvwrVe6hOyN4/M3oKbeL00MDlfRUsRW user@user-virtual-machine"
}

variable "auth_token" {
  type    = string
  default = "y0_AgAAAABx-Mm4AATuwQAAAADxx202D_bTb2ACQS-kYjFD9Ids8d6eewc"
}

variable "cloud_id_variable" {
  type    = string
  default = "b1g73nnahnk820brr5up"
}

variable "folder_id_variable" {
  type    = string
  default = "b1ghlehokvsh6kmdg74q"
}
