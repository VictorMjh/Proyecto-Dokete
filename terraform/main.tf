terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# ========================
# Red Docker
# ========================
resource "docker_network" "proxy_net" { 
  name = var.network_name #se comenta para evitar el error de que ya existe
}

# ========================
# Imágenes
# ========================
resource "docker_image" "nginx" {
  name = "nginx:alpine"
}

resource "docker_image" "mariadb" {
  name = "mariadb"
}

resource "docker_image" "nextcloud" {
  name = "nextcloud"
}

resource "docker_image" "homeassistant" {
  name = "ghcr.io/home-assistant/home-assistant:stable"
}

resource "docker_image" "plex" {
  name = "linuxserver/plex"
}

#resource "docker_image" "retroarch" {
#  name = "es20490446e/retroarch-web"
#}

resource "docker_image" "portainer" {
  name = "portainer/portainer-ce"
}

resource "docker_image" "watchtower" {
  name = "containrrr/watchtower"
}

# ========================
# Contenedores
# ========================

# Nginx Proxy
resource "docker_container" "nginx_proxy" {
  name    = "nginx-proxy"
  image   = docker_image.nginx.image_id
  restart = "unless-stopped"

  ports {
    internal = 80
    external = 80
  }

  volumes {
    host_path      = "/home/deploy/proyecto-dokete/docker/nginx/nginx.conf"
    container_path = "/etc/nginx/nginx.conf"
    read_only      = true
  }

  networks_advanced {
    name = docker_network.proxy_net.name
  }

  depends_on = [
    docker_container.nextcloud,
    docker_container.homeassistant,
    docker_container.plex,
    #docker_container.retroarch
  ]
}

# MariaDB
resource "docker_container" "nextcloud_db" {
  name    = "nextcloud-db"
  image   = docker_image.mariadb.image_id
  restart = "unless-stopped"

  env = [
    "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}",
    "MYSQL_DATABASE=${var.mysql_database}",
    "MYSQL_USER=${var.mysql_user}",
    "MYSQL_PASSWORD=${var.mysql_password}"
  ]

  volumes {
    host_path      = "${abspath(path.module)}/../docker/nextcloud_db"
    container_path = "/var/lib/mysql"
  }

  networks_advanced {
    name = docker_network.proxy_net.name
  }
}

# Nextcloud
resource "docker_container" "nextcloud" {
  name       = "nextcloud"
  image      = docker_image.nextcloud.image_id
  depends_on = [docker_container.nextcloud_db]
  restart    = "unless-stopped"

  env = [
    "MYSQL_PASSWORD=${var.mysql_password}",
    "MYSQL_DATABASE=${var.mysql_database}",
    "MYSQL_USER=${var.mysql_user}",
    "MYSQL_HOST=nextcloud-db"
  ]

  volumes {
    host_path      = "${abspath(path.module)}/../docker/nextcloud_data"
    container_path = "/var/www/html"
  }

  networks_advanced {
    name = docker_network.proxy_net.name
  }
}

# Home Assistant
resource "docker_container" "homeassistant" {
  name       = "homeassistant"
  image      = docker_image.homeassistant.image_id
  restart    = "unless-stopped"
  privileged = true

  volumes {
    host_path      = "${abspath(path.module)}/../docker/homeassistant_config"
    container_path = "/config"
  }

  volumes {
    host_path      = "/etc/localtime"
    container_path = "/etc/localtime"
    read_only      = true
  }

  networks_advanced {
    name = docker_network.proxy_net.name
  }
}

# Plex
resource "docker_container" "plex" {
  name    = "plex"
  image   = docker_image.plex.image_id
  restart = "unless-stopped"

  env = [
    "PUID=${var.puid}",
    "PGID=${var.pgid}",
    "VERSION=docker"
  ]

  ports {
    internal = 32400
    external = 32400
  }

  volumes {
    host_path      = "${abspath(path.module)}/../docker/plex_config"
    container_path = "/config"
  }

  volumes {
    host_path      = "${abspath(path.module)}/../docker/plex_media"
    container_path = "/media"
  }

  volumes {
    host_path      = "${abspath(path.module)}/../docker/plex_transcode"
    container_path = "/transcode"
  }

  networks_advanced {
    name = docker_network.proxy_net.name
  }
}

# Retroarch
#resource "docker_container" "retroarch" {
#  name    = "retroarch"
#  image   = docker_image.retroarch.image_id
#  restart = "unless-stopped"
#
#  networks_advanced {
#    name = docker_network.proxy_net.name
#  }
#}

# Portainer
resource "docker_container" "portainer" {
  name    = "portainer"
  image   = docker_image.portainer.image_id
  restart = "unless-stopped"

  ports {
    internal = 9000
    external = 9000
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  volumes {
    host_path      = "${abspath(path.module)}/../docker/portainer_data"
    container_path = "/data"
  }

  networks_advanced {
    name = docker_network.proxy_net.name
  }
}

# Watchtower
resource "docker_container" "watchtower" {
  name    = "watchtower"
  image   = docker_image.watchtower.image_id
  restart = "unless-stopped"

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  networks_advanced {
    name = docker_network.proxy_net.name
  }
}
#
