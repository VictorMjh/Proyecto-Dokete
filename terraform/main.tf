terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Docker Network
resource "docker_network" "proxy_net" {
  name = var.network_name
}

# ========== IMÁGENES ==========

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

resource "docker_image" "retroarch" {
  name = "es20490446e/retroarch-web"
}

resource "docker_image" "portainer" {
  name = "portainer/portainer-ce"
}

resource "docker_image" "watchtower" {
  name = "containrrr/watchtower"
}

# ========== CONTENEDORES ==========

# Nginx Proxy
resource "docker_container" "nginx_proxy" {
  name   = "nginx-proxy"
  image  = docker_image.nginx
  restart = "unless-stopped"

  ports {
    internal = 80
    external = 80
  }

  volumes = [
    "${abspath(path.module)}/../docker/nginx/nginx.conf:/etc/nginx/nginx.conf:ro"
  ]

  networks_advanced {
    name = docker_network.proxy_net.name
  }

  depends_on = [
    docker_container.nextcloud,
    docker_container.homeassistant,
    docker_container.plex,
    docker_container.retroarch
  ]
}

# MariaDB
resource "docker_container" "nextcloud_db" {
  name   = "nextcloud-db"
  image  = docker_image.mariadb
  restart = "unless-stopped"

  env = [
    "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}",
    "MYSQL_DATABASE=${var.mysql_database}",
    "MYSQL_USER=${var.mysql_user}",
    "MYSQL_PASSWORD=${var.mysql_password}"
  ]

  volumes = [
    "${abspath(path.module)}/../docker/nextcloud_db:/var/lib/mysql"
  ]

  networks_advanced {
    name = docker_network.proxy_net.name
  }
}

# Nextcloud
resource "docker_container" "nextcloud" {
  name   = "nextcloud"
  image  = docker_image.nextcloud
  depends_on = [docker_container.nextcloud_db]
  restart = "unless-stopped"

  env = [
    "MYSQL_PASSWORD=${var.mysql_password}",
    "MYSQL_DATABASE=${var.mysql_database}",
    "MYSQL_USER=${var.mysql_user}",
    "MYSQL_HOST=nextcloud-db"
  ]

  volumes = [
    "${abspath(path.module)}/../docker/nextcloud_data:/var/www/html"
  ]

  networks_advanced {
    name = docker_network.proxy_net.name
  }
}

# Home Assistant
resource "docker_container" "homeassistant" {
  name   = "homeassistant"
  image  = docker_image.homeassistant
  restart = "unless-stopped"
  privileged = true

  volumes = [
    "${abspath(path.module)}/../docker/homeassistant_config:/config",
    "/etc/localtime:/etc/localtime:ro"
  ]

  networks_advanced {
    name = docker_network.proxy_net.name
  }
}

# Plex
resource "docker_container" "plex" {
  name   = "plex"
  image  = docker_image.plex
  restart = "unless-stopped"

  env = [
    "PUID=${var.puid}",
    "PGID=${var.pgid}",
    "VERSION=docker"
  ]

  ports = [
    {
      internal = 32400
      external = 32400
    }
  ]

  volumes = [
    "${abspath(path.module)}/../docker/plex_config:/config",
    "${abspath(path.module)}/../docker/plex_media:/media",
    "${abspath(path.module)}/../docker/plex_transcode:/transcode"
  ]

  networks_advanced {
    name = docker_network.proxy_net.name
  }
}

# Retroarch
resource "docker_container" "retroarch" {
  name   = "retroarch"
  image  = docker_image.retroarch
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.proxy_net.name
  }
}

# Portainer
resource "docker_container" "portainer" {
  name   = "portainer"
  image  = docker_image.portainer
  restart = "unless-stopped"

  ports = [
    {
      internal = 9000
      external = 9000
    }
  ]

  volumes = [
    "/var/run/docker.sock:/var/run/docker.sock",
    "${abspath(path.module)}/../docker/portainer_data:/data"
  ]

  networks_advanced {
    name = docker_network.proxy_net.name
  }
}

# Watchtower
resource "docker_container" "watchtower" {
  name   = "watchtower"
  image  = docker_image.watchtower
  restart = "unless-stopped"

  volumes = [
    "/var/run/docker.sock:/var/run/docker.sock"
  ]

  networks_advanced {
    name = docker_network.proxy_net.name
  }
}
