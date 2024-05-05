#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 DOMAIN BACKUP_DATE"
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
    echo "Successful to retrieve ${field_name} for domain ${DOMAIN}"
}

# Assign command-line arguments to variables
DOMAIN=$1
BACKUP_DATE=$2

WP_DIR="$HOME/public_html/${DOMAIN}"
BACKUP_DIR="$HOME/wp/wp_backup/${DOMAIN}"
BACKUP_DB="$BACKUP_DIR/${DOMAIN}-db-$BACKUP_DATE.sql"
BACKUP_FILE="$BACKUP_DIR/${DOMAIN}-wp-files-$BACKUP_DATE.tar.gz"

# Retrieve database credentials
echo "Retrieving database credentials..."
DB_NAME=$(retrieve_from_1password "wp_db_name")
DB_USER=$(retrieve_from_1password "wp_db_user")
DB_PASSWORD=$(retrieve_from_1password "wp_db_password")

# Check if the backup files exist
if [ ! -f "$BACKUP_DB" ] || [ ! -f "$BACKUP_FILE" ]; then
    echo "Backup files not found. Please check the backup date and domain."
    exit 1
fi

# Restore database

# Create WordPress Database and User config for auto login to mysql
tee ~/.my.cnf <<EOM
[client]
user=$DB_USER
password=$DB_PASSWORD
EOM

chmod 600 ~/.my.cnf

echo "Restoring database from $BACKUP_DB..."
mysql "$DB_NAME" < "$BACKUP_DB"
echo "Database restoration completed."

# Restore WordPress files
echo "Restoring WordPress files from $BACKUP_FILE to $WP_DIR..."
# Ensure the directory exists and is empty
rm -rf "$WP_DIR"
mkdir -p "$WP_DIR"
tar -xzf "$BACKUP_FILE" -C "$WP_DIR"
echo "WordPress files restoration completed."

echo "Restoration of WordPress files and database for $DOMAIN completed successfully."
