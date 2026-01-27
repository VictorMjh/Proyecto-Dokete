#!/bin/bash
# Script para crear usuario 'deploy' con permisos mínimos seguros para AWX + Docker

set -e

echo "=== Creando usuario deploy con permisos mínimos ==="

# 1. Crear usuario deploy si no existe
if id "deploy" &>/dev/null; then
    echo "✓ Usuario 'deploy' ya existe"
else
    echo "→ Creando usuario deploy..."
    sudo useradd -m -s /bin/bash -d /home/deploy deploy
    echo "✓ Usuario deploy creado"
fi

# 2. Agregar a grupo docker (para evitar usar sudo con docker)
echo "→ Agregando deploy al grupo docker..."
sudo usermod -aG docker deploy
echo "✓ Usuario agregado a grupo docker"

# 3. Crear directorio /docker con permisos para deploy
echo "→ Creando directorio /docker..."
sudo mkdir -p /docker
sudo chown deploy:deploy /docker
sudo chmod 755 /docker
echo "✓ Directorio /docker creado y asignado a deploy"

# 4. Configurar sudoers MÍNIMOS - solo lo necesario para Ansible
echo "→ Configurando sudoers..."
sudo tee /etc/sudoers.d/deploy-minimal > /dev/null <<EOF
# Permisos mínimos para deploy - solo lo necesario para Ansible + Docker
deploy ALL=(ALL) NOPASSWD: /usr/bin/apt-get update
deploy ALL=(ALL) NOPASSWD: /usr/bin/apt-get install*
deploy ALL=(ALL) NOPASSWD: /usr/bin/apt-key*
deploy ALL=(ALL) NOPASSWD: /usr/bin/apt-add-repository
deploy ALL=(ALL) NOPASSWD: /usr/sbin/ufw
deploy ALL=(ALL) NOPASSWD: /bin/systemctl
deploy ALL=(ALL) NOPASSWD: /bin/mkdir
deploy ALL=(ALL) NOPASSWD: /bin/chown
deploy ALL=(ALL) NOPASSWD: /bin/chmod
deploy ALL=(ALL) NOPASSWD: /usr/bin/tee
EOF
sudo chmod 0440 /etc/sudoers.d/deploy-minimal
echo "✓ Sudoers configurado"

# 5. Crear directorio .ssh para la clave
echo "→ Creando directorio .ssh..."
sudo mkdir -p /home/deploy/.ssh
sudo chmod 700 /home/deploy/.ssh
echo "✓ Directorio .ssh creado"

echo ""
echo "=== ✓ Usuario deploy configurado correctamente ==="
echo ""
echo "Pasos restantes:"
echo "1. Copiar la clave pública a /home/deploy/.ssh/authorized_keys"
echo "2. Ajustar permisos:"
echo "   sudo chown deploy:deploy /home/deploy/.ssh -R"
echo "   sudo chmod 600 /home/deploy/.ssh/authorized_keys"
echo ""
echo "Verificar:"
echo "   sudo -l -U deploy"
echo ""
