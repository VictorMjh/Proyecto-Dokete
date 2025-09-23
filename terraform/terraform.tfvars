# --- Netwok ---
NETWORK_NAME="proxy_net"

# --- MSQL ---
# mysql_root_password = "" # Alojado en GIT Secrets
mysql_database      = "nextcloud"
mysql_user          = "nextcloud"
mysql_password      = "" # Alojado en GIT Secrets
puid                = 1000
pgid                = 1000

# --- Opcional: personalizar rutas/puertos ---
data_path       = "/home/deploy/proyecto-dokete/docker"
nginx_port      = 8080
plex_port       = 32400
portainer_port  = 9443
