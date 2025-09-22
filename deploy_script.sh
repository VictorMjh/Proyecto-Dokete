#!/bin/bash

set -e  # Detener si hay errores

# --- CONFIGURACIÓN GENERAL ---
COMPOSE_FILE="docker-compose.yml"
NETWORK_NAME="proxy_net"

echo "🔧 Verificando que Docker y Docker Compose estén instalados..."

if ! command -v docker &> /dev/null; then
  echo "❌ Docker no está instalado. Aborta."
  exit 1
fi

if ! docker network ls | grep -q "$NETWORK_NAME"; then
  echo "🌐 Creando red Docker externa: $NETWORK_NAME"
  docker network create "$NETWORK_NAME"
else
  echo "✅ Red Docker '$NETWORK_NAME' ya existe."
fi

echo "🚀 Desplegando servicios con Docker Compose..."
docker compose -f "$COMPOSE_FILE" up -d --build

echo "📦 Listado de contenedores activos:"
docker ps

echo "✅ Despliegue completo."
