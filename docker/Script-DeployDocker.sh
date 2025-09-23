#!/bin/bash
set -e  # Detener si hay errores

echo "🔄 Actualizando paquetes..."
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release

echo "🔧 Verificando si Docker está instalado..."
if ! command -v docker &> /dev/null; then
  echo "Docker no está instalado. Instalando desde repos oficiales..."
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo systemctl enable --now docker
else
  echo "✅ Docker ya está instalado."
fi

# Asegurar que docker esté en marcha
sudo systemctl start docker
sudo systemctl enable docker

echo "📦 Docker instalado y listo. Contenedores activos:"
docker ps
