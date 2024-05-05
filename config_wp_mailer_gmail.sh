#!/bin/bash

DOMAIN=$1
DOMAIN_="${DOMAIN//./_}"

# Check if domain is provided
if [ -z "$DOMAIN" ]; then
    echo "Usage: $0 DOMAIN"
    exit 1
fi

# retrieve - CLIENT_ID and CLIENT_SECRET from 1password
CLIENT_ID=$(op read "op://Private/${DOMAIN}/client_id")
if [ $? -ne 0 ]; then
    echo "Failed to retrieve CLIENT_ID for domain ${DOMAIN}"
    exit 1
fi

CLIENT_SECRET=$(op read "op://Private/${DOMAIN}/client_secret")
if [ $? -ne 0 ]; then
    echo "Failed to retrieve CLIENT_SECRET for domain ${DOMAIN}"
    exit 1
fi

echo "CLIENT_ID and CLIENT_SECRET retrieved successfully."

WP_DIR="/home2/simonho4/public_html/${DOMAIN_}"
cd $WP_DIR

# Check if WP-CLI is installed
if ! command -v wp &> /dev/null
then
    echo "WP-CLI could not be found. Please install WP-CLI."
    exit
fi

# Check if the plugin is installed, install if not
PLUGIN="wp-mail-smtp" # WP Mail SMTP

if ! wp plugin is-installed $PLUGIN; then
    echo "WP Mail SMTP plugin not found. Installing now..."
    wp plugin install $PLUGIN --activate
else
    echo "WP Mail SMTP plugin is already installed."
fi

# Activate the plugin if it is not already active
if ! wp plugin is-active $PLUGIN; then
    wp plugin activate $PLUGIN
fi

# Navigate to your WordPress directory
# Update this path to the directory where your WordPress is installed

# Configure WP Mail SMTP settings to use Gmail
JSON_STRING=$(cat <<EOM
{
    "mail": {
        "from_email": "contact@${DOMAIN}",
        "from_name": "Contact from https://${DOMAIN}",
        "mailer": "gmail",
        "return_path": true
    },
    "smtp": {
        "host": "smtp.gmail.com",
        "port": "465",
        "encryption": "ssl",
        "auth": true,
        "user": "your-email@example.com",
        "pass": "your-email-password"
    },
    "gmail": {
        "client_id": "${CLIENT_ID}",
        "client_secret": "${CLIENT_SECRET}"
    }
}
EOM
)
wp option update wp_mail_smtp "$JSON_STRING" --format=json

# synchronize server and local machine timezone because OAuth relies on timestamp verification
tee -a .htaccess <<EOM

php_value date.timezone "America/Los_Angeles"

EOM

echo "WP Mail SMTP configuration updated successfully."

