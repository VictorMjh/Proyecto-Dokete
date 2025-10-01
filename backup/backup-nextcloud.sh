#!/bin/bash
# ==========================================
# Backup automático de Nextcloud + MariaDB
# ==========================================

# Configuración
BACKUP_DIR="/home/deploy/backups"
DATA_PATH="/home/deploy/proyecto-dokete"   # donde montaste volúmenes en el compose
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

# Nombre de contenedor de la base de datos
DB_CONTAINER="nextcloud-db"
DB_NAME="nextcloud"
DB_USER="nextcloud"
DB_PASS="example_pass"   # ⚠️ cámbialo por el valor de tu .env o usa secrets

# Crear carpeta de backup si no existe
mkdir -p "$BACKUP_DIR/$TIMESTAMP"

echo "📦 Iniciando backup de Nextcloud en $BACKUP_DIR/$TIMESTAMP ..."

# 1. Backup de la base de datos MariaDB
echo "💾 Dump de base de datos MariaDB..."
docker exec $DB_CONTAINER \
  mysqldump -u$DB_USER -p$DB_PASS $DB_NAME > "$BACKUP_DIR/$TIMESTAMP/nextcloud-db.sql"

# 2. Backup de datos y configuraciones (bind mounts)
echo "📂 Copiando carpetas bind mounts..."
rsync -a --delete "$DATA_PATH/nextcloud_data/" "$BACKUP_DIR/$TIMESTAMP/nextcloud_data/"
rsync -a --delete "$DATA_PATH/nextcloud_config/" "$BACKUP_DIR/$TIMESTAMP/nextcloud_config/"
rsync -a --delete "$DATA_PATH/nextcloud_html/" "$BACKUP_DIR/$TIMESTAMP/nextcloud_html/"

# 3. Comprimir backup completo
echo "📦 Comprimiendo backup..."
tar -czf "$BACKUP_DIR/nextcloud-backup-$TIMESTAMP.tar.gz" -C "$BACKUP_DIR/$TIMESTAMP" .

# 4. Limpiar archivos temporales (mantén solo .tar.gz)
rm -rf "$BACKUP_DIR/$TIMESTAMP"

echo "✅ Backup completado: $BACKUP_DIR/nextcloud-backup-$TIMESTAMP.tar.gz"
