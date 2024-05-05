#!/bin/bash

# Check if domain was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

# Set Variables
DOMAIN=$1
DOMAIN_="${DOMAIN//./_}"
PREFIX="simonho4_"

WP_DIR="/home2/simonho4/public_html/${DOMAIN_}"
DB_NAME="${PREFIX}${DOMAIN_}"
DB_USER="${PREFIX}${DOMAIN_}"
DB_PASSWORD="hwcPv1xbZTTGme9J"
# $(openssl rand -base64 12)  # Generating a random password for MySQL user
# DB_HOST="localhost"  # Typical for many shared hosting environments; adjust if necessary

# Create site directory
echo "Creating website directory..."
mkdir -p "$WP_DIR"
cd "$WP_DIR"

# Download WordPress
echo "Downloading WordPress..."
wp core download --path="$WP_DIR"

# Create a new database and user
# echo "Creating new MySQL database and user..."
mysql -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;"

# mysql -e "CREATE USER IF NOT EXISTS \`${DB_USER}\`@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
# mysql -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO \`${DB_USER}\`@'localhost';"
# mysql -e "FLUSH PRIVILEGES;"

# Create wp-config.php
echo "Configuring WordPress..."
cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/${DB_NAME}/" wp-config.php
sed -i "s/username_here/${DB_USER}/" wp-config.php
sed -i "s/password_here/${DB_PASSWORD}/" wp-config.php

# Install WordPress
echo "Installing WordPress..."
ADMIN_USER="five9"
ADMIN_PASSWORD="$(openssl rand -base64 12)"
TITLE="New WordPress Site"

# wp core install --url="$DOMAIN" --title="$TITLE" --admin_user="$ADMIN_USER" --admin_password="$ADMIN_PASSWORD" --admin_email="$ADMIN_USER@$DOMAIN" --path="$WP_DIR"

# Install the Theme
wp theme install $DOMAIN_/theme.zip

# echo "WordPress installation completed successfully!"
# echo "Admin URL: http://$DOMAIN/wp-admin"
# echo "Admin user: ${ADMIN_USER}"
# echo "Admin password: ${ADMIN_PASSWORD}"
# echo "Local folder: ${WP_DIR}"
# echo "Database name: ${DB_NAME}"
# echo "Database user: ${DB_USER}"

