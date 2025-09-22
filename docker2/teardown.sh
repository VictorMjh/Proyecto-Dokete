#!/bin/bash

# Cargar variables desde .env
set -o allexport
source .env
set +o allexport

echo "🧹 Apagando y limpiando stack definido en $COMPOSE_FILE"
docker compose -f "$COMPOSE_FILE" down

# Preguntar si se desea eliminar la red
read -p "¿Quieres eliminar la red Docker '$NETWORK_NAME'? [y/N]: " RESP
if [[ "$RESP" == "y" || "$RESP" == "Y" ]]; then
  echo "🗑️  Eliminando red '$NETWORK_NAME'..."
  docker network rm "$NETWORK_NAME"
else
  echo "ℹ️  Red '$NETWORK_NAME' conservada."
fi

echo "✅ Limpieza completada."
#