#!/bin/bash
# Actualizar el sistema
sudo apt update && sudo apt upgrade -y
# Instalar Docker si no está instalado
if ! command -v docker &> /dev/null
then
  echo "Docker no está instalado. Instalando..."
  sudo apt install -y docker.io
  sudo systemctl enable --now docker
fi
# Asegurarse de que Docker esté en funcionamiento
sudo systemctl start docker
sudo systemctl enable docker
# Ejecutar contenedor de ejemplo (puedes personalizar esto)
sudo docker run -d --name mi_contenedor -p 80:80 nginx
