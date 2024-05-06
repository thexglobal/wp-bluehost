#!/bin/bash

# Check if domain was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

# Set Variables
DOMAIN=$1
DOMAIN_="${DOMAIN//./_}"
PREFIX="simonho4"
WP_URL=https://$DOMAIN

if [[ "$DOMAIN" == "simonholding.us" ]]; then
    WP_DIR="/home2/${PREFIX}/public_html"
else
    WP_DIR="/home2/${PREFIX}/public_html/${DOMAIN_}"
fi

DB_NAME="${PREFIX}_${DOMAIN_}"
DB_PREFIX="wp_"
DB_USER="${PREFIX}_${DOMAIN_}"
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
# wp config create --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASSWORD --dbprefix=$DB_PREFIX --force --allow-root

cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/${DB_NAME}/" wp-config.php
sed -i "s/username_here/${DB_USER}/" wp-config.php
sed -i "s/password_here/${DB_PASSWORD}/" wp-config.php
sed -i "s/wp_/${DB_PREFIX}/" wp-config.php
sed -i "s|http://example.com|${WP_URL}|g" wp-config.php

# Fetch new unique security keys from the WordPress API and update wp-config.php
curl -s https://api.wordpress.org/secret-key/1.1/salt/ -o salt.txt

if [ -s salt.txt ]; then
    # Ensure the salt file isn't empty to prevent accidental removal of keys
    # Delete old keys
    sed -i '/AUTH_KEY/d' wp-config.php
    sed -i '/SECURE_AUTH_KEY/d' wp-config.php
    sed -i '/LOGGED_IN_KEY/d' wp-config.php
    sed -i '/NONCE_KEY/d' wp-config.php
    sed -i '/AUTH_SALT/d' wp-config.php
    sed -i '/SECURE_AUTH_SALT/d' wp-config.php
    sed -i '/LOGGED_IN_SALT/d' wp-config.php
    sed -i '/NONCE_SALT/d' wp-config.php

    # Insert new keys before the "stop editing" line
    sed -i "/^\/\* That's all, stop editing! Happy publishing. \*\//e cat salt.txt" wp-config.php

else
    echo "Failed to fetch new security keys. Check your internet connection."
fi

# Clean up
rm -f salt.txt

echo "WordPress configure was completed successfully."
echo "Open URL to install: $WP_URL"
echo "Local folder: ${WP_DIR}"

# Install WordPress
# echo "Installing WordPress..."
# ADMIN_USER="admin"
# ADMIN_PASSWORD="$(openssl rand -base64 12)"
# TITLE="New WordPress Site"

# wp core install --url="$DOMAIN" --title="$TITLE" --admin_user="$ADMIN_USER" --admin_password="$ADMIN_PASSWORD" --admin_email="$ADMIN_USER@$DOMAIN" --path="$WP_DIR"

# echo "WordPress installation completed successfully!"
# echo "Admin URL: http://$DOMAIN/wp-admin"
# echo "Admin user: ${ADMIN_USER}"
# echo "Admin password: ${ADMIN_PASSWORD}"
# echo "Local folder: ${WP_DIR}"
# echo "Database name: ${DB_NAME}"
# echo "Database user: ${DB_USER}"

