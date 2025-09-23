variable "network_name" {
  type    = string
  default = "proxy_net"
}

variable "data_path" {
  type    = string
  default = "/home/deploy/proyecto-dokete/docker"
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

variable "nginx_port" {
  type    = number
  default = 80
}

variable "plex_port" {
  type    = number
  default = 32400
}

variable "portainer_port" {
  type    = number
  default = 9000
}
