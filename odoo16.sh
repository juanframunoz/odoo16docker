#!/bin/bash

# Actualizar el sistema
echo "Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar Docker
echo "Instalando Docker..."
sudo apt install docker.io -y

# Iniciar y habilitar Docker
echo "Iniciando y habilitando Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# Instalar Docker Compose
echo "Instalando Docker Compose..."
sudo apt install docker-compose -y

# Crear directorio para Odoo
echo "Creando directorio para Odoo..."
mkdir -p ~/odoo16 && cd ~/odoo16

# Crear archivo docker-compose.yml
echo "Creando archivo docker-compose.yml..."
cat <<EOL > docker-compose.yml
version: '3.1'
services:
  web:
    image: odoo:16.0
    depends_on:
      - db
    ports:
      - "8069:8069"
    volumes:
      - odoo-data:/var/lib/odoo
    environment:
      - HOST=db
      - USER=odoo
      - PASSWORD=odoo

  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=postgres
      - POSTGRES_USER=odoo
      - POSTGRES_PASSWORD=odoo
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  odoo-data:
  postgres-data:
EOL

# Iniciar Odoo con Docker Compose
echo "Iniciando Odoo 16 con Docker Compose..."
docker-compose up -d

# Mostrar mensaje final
echo "¡Odoo 16 se ha instalado correctamente!"
echo "Accede a Odoo en: http://<IP_DEL_SERVIDOR>:8069"
