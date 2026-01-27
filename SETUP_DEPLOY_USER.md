# Setup Usuario Deploy para AWX

## 📋 Resumen

Este documento explica cómo crear el usuario `deploy` con **permisos mínimos** necesarios para:
- Conectarse por SSH desde AWX
- Ejecutar los playbooks de Ansible
- Desplegar contenedores Docker

## 🔐 Permisos Configurados

| Permiso | Razón |
|---------|-------|
| `usermod -aG docker` | Ejecutar `docker` sin `sudo` |
| `apt-get update/install` | Instalar paquetes necesarios |
| `apt-key / apt-add-repository` | Agregar repositorios (Docker, etc) |
| `ufw` | Configurar firewall |
| `systemctl` | Iniciar/detener servicios |
| `mkdir / chown / chmod` | Crear directorios y asignar permisos |
| `tee` | Escribir archivos de configuración |

## ✅ Pasos de Setup

### 1️⃣ En tu servidor Ubuntu (como usuario con sudo)

Ejecuta el script preparado:

```bash
# Opción A: Descargar y ejecutar directamente
curl -fsSL https://raw.githubusercontent.com/VictorMjh/Proyecto-Dokete/main/setup-deploy-user.sh | bash

# Opción B: Ejecutar localmente
bash setup-deploy-user.sh
```

O ejecuta los comandos manualmente:

```bash
# Crear usuario
sudo useradd -m -s /bin/bash -d /home/deploy deploy

# Agregar a docker
sudo usermod -aG docker deploy

# Crear /docker
sudo mkdir -p /docker
sudo chown deploy:deploy /docker
sudo chmod 755 /docker

# Configurar sudoers mínimos
sudo tee /etc/sudoers.d/deploy-minimal > /dev/null <<'EOF'
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

# Crear directorio SSH
sudo mkdir -p /home/deploy/.ssh
sudo chmod 700 /home/deploy/.ssh
```

### 2️⃣ Agregar clave SSH pública

En el servidor Ubuntu, como usuario `deploy`:

```bash
# Copiar clave pública (desde tu máquina local)
cat ~/.ssh/ansible_awx.pub | sudo tee -a /home/deploy/.ssh/authorized_keys

# O manualmente:
sudo nano /home/deploy/.ssh/authorized_keys
# Pegar contenido de AWX/Ansible_awx.pub

# Ajustar permisos
sudo chown deploy:deploy /home/deploy/.ssh -R
sudo chmod 600 /home/deploy/.ssh/authorized_keys
```

### 3️⃣ Verificar configuración

```bash
# Ver permisos de sudo del usuario deploy
sudo -l -U deploy

# Probar conexión SSH
ssh -i ~/.ssh/ansible_awx deploy@192.168.0.151

# Verificar acceso a docker
ssh -i ~/.ssh/ansible_awx deploy@192.168.0.151 docker ps

# Verificar acceso a /docker
ssh -i ~/.ssh/ansible_awx deploy@192.168.0.151 ls -la /docker
```

## 🔧 Configurar AWX

### Machine Credential

1. En AWX → **Credentials** → **Create New**
2. **Name**: `Doketer Deploy SSH`
3. **Credential Type**: `Machine`
4. **Username**: `deploy`
5. **SSH Private Key**: (copiar contenido de clave privada)
6. **Privilege Escalation Method**: `sudo`
7. **Privilege Escalation Username**: `deploy`
8. **Privilege Escalation Password**: Dejar vacío (está en sudoers)

### Inventory

1. En AWX → **Inventories** → **Create New**
2. **Name**: `Doketer Hosts`
3. Agregar hosts desde archivo `inventory.yaml` o manualmente:
   - **Host**: `doketer-vic-01`
   - **Variables**: 
     ```yaml
     ansible_host: 192.168.0.151
     ansible_user: deploy
     ```

### Project

1. En AWX → **Projects** → **Create New**
2. **Name**: `Doketer`
3. **Source Control Type**: `Git`
4. **Source Control URL**: `https://github.com/VictorMjh/Proyecto-Dokete.git`

### Job Template

1. En AWX → **Templates** → **Create New Job Template**
2. **Name**: `Deploy Doketer`
3. **Project**: `Doketer`
4. **Playbook**: `playbooks/site.yml`
5. **Credentials**: `Doketer Deploy SSH`
6. **Inventory**: `Doketer Hosts`
7. **Enable Privilege Escalation**: ✓
8. **Limit**: `doketer-vic-01`

## 📝 Notas Importantes

### Seguridad
- El usuario `deploy` **NO tiene acceso a toda la máquina**, solo a lo necesario
- No puede instalar software arbitrario, solo lo que Ansible necesita
- No puede cambiar configuraciones de sistema fuera del playbook
- Docker se ejecuta sin `sudo` (es su grupo de pertenencia)

### Archivos de Configuración
- El playbook crea archivos bajo `/docker` (propiedad: deploy)
- El playbook crea volúmenes Docker (manejo automático)
- Certificados Let's Encrypt se generan en `/docker`

### Troubleshooting

**"Permission denied" al conectar SSH**
```bash
# Verificar que la clave privada es correcta
ssh-keygen -l -f ~/.ssh/ansible_awx
```

**"deploy: command not found" en sudoers**
```bash
# Usar ruta completa en sudoers
sudo visudo -f /etc/sudoers.d/deploy-minimal
# Cambiar: /bin/mkdir → /usr/bin/mkdir (ajustar según `which`)
```

**Docker: "permission denied while trying to connect to Docker daemon"**
```bash
# Verificar grupo docker
groups deploy

# Si no aparece 'docker', el usuario necesita reloguear (nueva sesión SSH)
# O: sudo usermod -aG docker deploy
```

## 🎯 Siguiente Paso

Una vez configurado:
1. Editar `inventory.yaml` para que apunte a la IP correcta
2. Actualizar credenciales en `group_vars/doketer.yaml` (mover a vault)
3. Crear Job Template en AWX
4. Ejecutar playbook

