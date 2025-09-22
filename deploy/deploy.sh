#!/bin/bash
set -e

echo "📦 Desplegando Nextcloud..."

cd ~/nextcloud-docker || exit 1

# Opcional: backup previo
# docker-compose down --volumes

git pull origin main

# Reconstruye si es necesario
docker-compose pull
docker-compose up -d

echo "✅ Despliegue completo."
