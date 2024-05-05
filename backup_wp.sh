#!/bin/bash

# Usage: ./backup_wp.sh domain.extension

# Check if the domain argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain.extension>"
    exit 1
fi

# Function to retrieve data from 1Password
retrieve_from_1password() {
    local field_name=$1
    local value=$(op read "op://Private/${DOMAIN}/${field_name}")
    if [ $? -ne 0 ]; then
        echo "Failed to retrieve ${field_name} for domain ${DOMAIN}"
        exit 1
    fi
    echo "$value"
}

DOMAIN=$1
DOMAIN_="${DOMAIN//./_}"

# Retrieve database credentials
echo "Retrieving database credentials..."
DB_NAME=$(retrieve_from_1password "wp_db_name")
DB_USER=$(retrieve_from_1password "wp_db_user")
DB_PASSWORD=$(retrieve_from_1password "wp_db_password")

WP_DIR="$HOME/public_html/${DOMAIN_}"  # The root directory of your WordPress installation
BACKUP_DIR="$HOME/wp/wp_backup/${DOMAIN_}"
DATE=$(date +"%Y-%m-%d")

# Create backup directory if it doesn't exist
echo "Create backup directory if it doesn't exist..."
mkdir -p "$BACKUP_DIR"

# Backup database
echo "Starting database backup..."
# mysqldump -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > "$BACKUP_DIR/${DOMAIN_}-db-$DATE.sql"ls 
mysqldump -e "$DB_NAME" > "$BACKUP_DIR/${DOMAIN_}-db-$DATE.sql"
echo "Database backup completed."

# Backup WordPress files
echo "Starting files backup..."
tar -czf "$BACKUP_DIR/${DOMAIN_}-wp-files-$DATE.tar.gz" -C "$WP_DIR" .
echo "Files backup completed."

echo "Backup of WordPress files and database for domain $DOMAIN completed successfully."
echo "Backup files are located in $BACKUP_DIR"
