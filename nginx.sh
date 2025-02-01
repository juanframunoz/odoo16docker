#!/bin/bash

# Configurar el firewall (ufw)
echo "Configurando el firewall..."
sudo apt install ufw -y
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable

# Instalar Certbot para obtener un certificado SSL
echo "Instalando Certbot..."
sudo apt install certbot python3-certbot-nginx -y

# Detener temporalmente el contenedor de Odoo para configurar SSL
echo "Deteniendo el contenedor de Odoo temporalmente..."
cd ~/odoo16
docker-compose down

# Configurar Nginx como proxy inverso para Odoo
echo "Instalando Nginx..."
sudo apt install nginx -y

# Crear un archivo de configuración de Nginx para Odoo
echo "Creando configuración de Nginx para Odoo..."
ODOO_DOMAIN="tudominio.com"  # Cambia esto por tu dominio
sudo bash -c "cat > /etc/nginx/sites-available/odoo <<EOL
server {
    listen 80;
    server_name $ODOO_DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:8069;
        proxy_set_header Host \\\$host;
        proxy_set_header X-Real-IP \\\$remote_addr;
        proxy_set_header X-Forwarded-For \\\$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \\\$scheme;
    }
}
EOL"

# Habilitar la configuración de Nginx
echo "Habilitando la configuración de Nginx..."
sudo ln -s /etc/nginx/sites-available/odoo /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# Obtener un certificado SSL con Certbot
echo "Obteniendo un certificado SSL con Certbot..."
sudo certbot --nginx -d $ODOO_DOMAIN --non-interactive --agree-tos --email tucorreo@example.com  # Cambia el correo

# Modificar el archivo docker-compose.yml para usar SSL
echo "Modificando docker-compose.yml para usar SSL..."
sed -i 's/- "8069:8069"/- "127.0.0.1:8069:8069"/g' docker-compose.yml

# Reiniciar los contenedores de Odoo
echo "Reiniciando los contenedores de Odoo..."
docker-compose up -d

# Mostrar mensaje final
echo "¡Servidor protegido y SSL configurado correctamente!"
echo "Accede a Odoo en: https://$ODOO_DOMAIN"
