# Base image with Apache (httpd)
FROM httpd:2.4

# Enable bash debugging and stop on error
SHELL ["/bin/bash", "-c"]
RUN set -ex

# Install necessary packages including PHP 8.3 and the required Apache PHP module
RUN apt-get update && apt-get install -y \
    apache2-utils \
    openssl \
    php8.3 libapache2-mod-php8.3 \
    && rm -rf /var/lib/apt/lists/*

# Enable PHP 8.3 module in Apache
RUN a2enmod php8.3

# Enable WebDAV and other Apache modules
RUN a2enmod dav dav_fs auth_digest

# Copy custom WebDAV configurations
COPY ./config/httpd.conf /usr/local/apache2/conf/custom/httpd.conf
COPY ./config/httpd-dav.conf /usr/local/apache2/conf/custom/httpd-dav.conf
COPY ./config/httpd-ssl.conf /usr/local/apache2/conf/custom/httpd-ssl.conf

# Copy the main page (index.html) into a temporary location inside the container
COPY ./web/index.html /tmp/index.html

# Copy the docker-entrypoint.sh script into the container
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Make sure the entrypoint script is executable
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create directories for persistent configuration
RUN mkdir -p /config

# Expose HTTP and HTTPS ports
EXPOSE 80 443

# Set the entrypoint to run the script
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# The default command to run Apache in the foreground
CMD ["httpd-foreground"]
