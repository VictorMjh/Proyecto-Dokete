variable "network_name" {
  type    = string
  default = "proxy_net"
}

variable "mysql_root_password" {
  type = string
}

variable "mysql_database" {
  type = string
}

variable "mysql_user" {
  type = string
}

variable "mysql_password" {
  type = string
}

variable "puid" {
  type = number
}

variable "pgid" {
  type = number
}
#