#!/bin/bash

set -e  # Detener si hay errores

# === Cargar variables desde el archivo .env ===
set -o allexport
source .env
set +o allexport

# === Actualizar el sistema ===
sudo apt update && sudo apt upgrade -y

# === Instalar docker si no esta instalado ===
echo "🔧 Verificando que Docker y Docker Compose estén instalados..."
if ! command -v docker &> /dev/null; then
  echo "Docker no está instalado. Instalando..."
  sudo apt install -y docker.io docker-compose
  sudo systemctl enable --now docker
fi

# === Opcional - Crear las red Docker externa ===
#if ! docker network ls | grep -q "$NETWORK_NAME"; then
#  echo "🌐 Creando red Docker externa: $NETWORK_NAME"
#  docker network create "$NETWORK_NAME"
#else
#  echo "✅ Red Docker '$NETWORK_NAME' ya existe."
#fi

# === Asegurarse de que Docker esté en funcionamiento ===
sudo systemctl start docker
sudo systemctl enable docker
echo "✅ Docker instalado y configurado. Listo para composer."

# === Opcional desplegar con composer - comentado ===
#echo "🚀 Desplegando servicios con Docker Compose..."
#docker-compose -f "$COMPOSE_FILE" up -d --build

# === Opcional Ejecutar contenedor de ejemplo (puedes personalizar esto) ===
# sudo docker run -d --name mi_contenedor -p 80:80 nginx

echo "📦 Listado de contenedores activos:"
docker ps
