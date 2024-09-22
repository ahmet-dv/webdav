#!/bin/bash
set -ex  # Enable debug mode and stop on error

# Define base paths
APACHE_PREFIX="/usr/local/apache2"
CONFIGPATH="/config/apache"
SSL_PATH="/config/ssl"
HTPASSWD_PATH="/config/htpasswd/.htpasswd"
HTTPD_PASSWD_PATH="$APACHE_PREFIX/user.passwd"
DATA_PATH="/data"
WEB_CONFIG_PATH="/config/web"
DOCUMENT_ROOT="/usr/local/apache2/htdocs"

# Optional: Do some setup before starting Apache (e.g., setting up user permissions, creating directories)
echo "Initializing WebDAV container..."

# Check if the config directory exists, fail if not
if [ ! -d "$CONFIGPATH" ]; then
    echo "Error: CONFIGPATH ($CONFIGPATH) does not exist. Please bind it as a volume in the Docker Compose file."
    exit 1
fi

# Check if the SSL directory exists, fail if not
if [ ! -d "$SSL_PATH" ]; then
    echo "Error: SSL_PATH ($SSL_PATH) does not exist. Please bind it as a volume in the Docker Compose file."
    exit 1
fi

# Check if the htpasswd directory exists, fail if not
if [ ! -d "/config/htpasswd" ]; then
    echo "Error: htpasswd directory does not exist. Please bind it as a volume in the Docker Compose file."
    exit 1
fi

# Check if the data directory exists, fail if not
if [ ! -d "$DATA_PATH" ]; then
    echo "Error: DATA_PATH ($DATA_PATH) does not exist. Please bind it as a volume in the Docker Compose file."
    exit 1
fi

# Ensure the web config directory exists and copy index.html if needed
if [ ! -d "$WEB_CONFIG_PATH" ]; then
    echo "Creating web config path $WEB_CONFIG_PATH..."
    mkdir -p "$WEB_CONFIG_PATH"
fi

# Copy the index.html to the persistent location if it does not already exist
if [ ! -f "$WEB_CONFIG_PATH/index.html" ]; then
    echo "Copying default index.html to $WEB_CONFIG_PATH..."
    cp /tmp/index.html "$WEB_CONFIG_PATH/index.html"
fi

# Link the index.html to the document root so that it can be updated from the persistent location
ln -sfn "$WEB_CONFIG_PATH/index.html" "$DOCUMENT_ROOT/index.html"

# Check if the .htpasswd file exists, and if not, create it
if [ ! -f "$HTPASSWD_PATH" ]; then
    echo ".htpasswd file not found, creating..."
    touch "$HTPASSWD_PATH"
else
    echo ".htpasswd file found."
fi

# Add default WebDAV user from environment variables
if [ -n "$WEBDAV_USER" ] && [ -n "$WEBDAV_PASSWORD" ]; then
    echo "Adding WebDAV user: $WEBDAV_USER"
    htpasswd -b "$HTPASSWD_PATH" "$WEBDAV_USER" "$WEBDAV_PASSWORD"
else
    echo "No WebDAV user added. Set WEBDAV_USER and WEBDAV_PASSWORD to add users."
fi

# Copy and link config files with error checks
for conf in "httpd.conf" "httpd-dav.conf" "httpd-ssl.conf"; do
    if [ ! -e "$CONFIGPATH/$conf" ]; then
        echo "Copying default $conf to $CONFIGPATH"
        cp "$APACHE_PREFIX/conf/custom/$conf" "$CONFIGPATH/"
    fi
    ln -sfn "$CONFIGPATH/$conf" "$APACHE_PREFIX/conf/$conf"
done

# Improved user management: Adding multiple users from environment variables (comma-separated)
if [ -n "$USERS" ]; then
    echo "Adding multiple users from USERS environment variable"
    IFS=',' read -r -a user_array <<< "$USERS"
    for user_pass in "${user_array[@]}"; do
        username=$(echo "$user_pass" | cut -d':' -f1)
        password=$(echo "$user_pass" | cut -d':' -f2)
        if [ -n "$username" ] && [ -n "$password" ]; then
            echo "Adding user: $username"
            htpasswd -B -b "$HTTPD_PASSWD_PATH" "$username" "$password"
        else
            echo "Error: Invalid user format for $user_pass. Expected format: username:password"
        fi
    done
#else
#    echo "Adding default user: webdav with password: webdav"
#    htpasswd -B -b -c "$HTTPD_PASSWD_PATH" "webdav" "webdav"
fi

# Set Server Name if provided
if [ -n "$SERVER_NAME" ]; then
    echo "Setting ServerName to $SERVER_NAME in httpd-ssl.conf"
    sed -i -e "s|ServerName .*|ServerName $SERVER_NAME|" "$CONFIGPATH/httpd-ssl.conf"
else
    echo "No SERVER_NAME provided, using default."
fi

# Generate self-signed certificate if not provided in the SSL_PATH
if [ ! -e "$SSL_PATH/server.key" ] || [ ! -e "$SSL_PATH/server.crt" ]; then
    echo "Generating self-signed SSL certificate for ${SERVER_NAME:-selfsigned}"
    openssl req -x509 -newkey rsa:4096 -days 9999 -nodes \
      -keyout "$SSL_PATH/server.key" \
      -out "$SSL_PATH/server.crt" \
      -subj "/CN=${SERVER_NAME:-selfsigned}"
else
    echo "SSL certificate and key already exist."
fi

# Link SSL certificates to the Apache config directory
ln -sfn "$SSL_PATH/server.key" "$APACHE_PREFIX/conf/server.key"
ln -sfn "$SSL_PATH/server.crt" "$APACHE_PREFIX/conf/server.crt"

# Start Apache in the foreground (default command)
exec "$@"
