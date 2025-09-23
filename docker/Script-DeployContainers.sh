#!/bin/bash
set -e  # Detener si hay errores

# Cargar variables desde el archivo .env
set -o allexport
source .env
set +o allexport

# --- Verificando que Docker y Docker Compose estén instalados ---
echo "🔧 Verificando que Docker y Docker Compose estén instalados..."
if ! command -v docker &> /dev/null; then
  echo "Docker no está instalado. Ejecutar Install Docker Workflow"
  exit 1
fi

# --- Verificar si la red existe, y si no, crearla ---
if ! docker network ls | grep -q "$NETWORK_NAME"; then
    echo "🔧 La red '$NETWORK_NAME' no existe. Creándola..."
    docker network create "$NETWORK_NAME"
else
    echo "✅ La red '$NETWORK_NAME' ya existe."
fi
echo "🔌 Red de Docker: $NETWORK_NAME"

# Asegurarse de que Docker esté en funcionamiento
sudo systemctl start docker
sudo systemctl enable docker

# Ejecutar contenedor de ejemplo (puedes personalizar esto)
# sudo docker run -d --name mi_contenedor -p 80:80 nginx

# --- 📦 Desplegando stack definido en el archivo compose ---
echo "📦 Desplegando stack definido en $COMPOSE_FILE"
docker compose -f "$COMPOSE_FILE" up -d

# Mostrar estado
echo "🚀 Stack desplegado. Contenedores activos:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
