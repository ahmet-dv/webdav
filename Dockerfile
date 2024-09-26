# Base image with Apache (httpd)
FROM httpd:2.4

# Enable bash debugging and stop on error
SHELL ["/bin/bash", "-c"]
RUN set -ex

ENV RUNLEVEL 1
RUN echo exit 0 > /usr/sbin/policy-rc.d

# Add Ondrej's repo source and signing key along with dependencies for PHP 8.3
RUN apt-get update && apt-get install -y apt-transport-https curl lsb-release \
    && curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && apt-get update

#RUN apt-get install -y dialog apt-utils
    
# Install PHP 8.3 and necessary extensions, including Apache PHP module
RUN apt-get install -y php8.3 php8.3-fpm php8.3-cli php8.3-bz2 php8.3-curl php8.3-mbstring php8.3-intl 
#RUN apt-get install -y libapache2-mod-php8.3 
#RUN apt-get install -y php8.3-fpm

RUN rm -rf /var/lib/apt/lists/*

#RUN a2dismod php8.3 
#RUN a2dismod mpm_prefork

RUN a2enmod proxy_fcgi proxy
#RUN a2enmod mpm_event
#RUN a2enconf php8.3-fpm

# Enable PHP 8.3 module in Apache
# RUN a2enmod php8.3

# Enable WebDAV and other Apache modules
RUN a2enmod dav dav_fs auth_digest authz_core


# Enable MPM Prefork module in Apache (for mod_php compatibility)
# RUN a2enmod mpm_prefork

# Copy custom WebDAV configurations
COPY ./config/httpd.conf /usr/local/apache2/conf/custom/httpd.conf
COPY ./config/httpd-dav.conf /usr/local/apache2/conf/custom/httpd-dav.conf
COPY ./config/httpd-ssl.conf /usr/local/apache2/conf/custom/httpd-ssl.conf

# Copy the main page (index.html) into a temporary location inside the container
COPY ./web/index.html /tmp/index.html

# Copy the docker-entrypoint.sh script into the container
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Copy the PHP user management interface into the container
COPY ./php_admin /var/www/html/admin

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
