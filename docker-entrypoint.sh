#!/bin/sh
set -ex

if [ -f "/config/httpd.conf" ]; then
	ln -sfn /config/httpd.conf $HTTPD_PREFIX/conf/httpd.conf
else
	cp $HTTPD_PREFIX/conf/httpd.conf /config/
fi
if [ -f "/config/httpd-dav.conf" ]; then
	ln -sfn /config/httpd-dav.conf $HTTPD_PREFIX/conf/extra/httpd-dav.conf
else
	cp $HTTPD_PREFIX/conf/extra/httpd-dav.conf /config/
fi
if [ -f "/config/httpd-ssl.conf" ]; then
	ln -sfn /config/httpd-ssl.conf $HTTPD_PREFIX/conf/extra/httpd-ssl.conf
else
	cp $HTTPD_PREFIX/conf/extra/httpd-ssl.conf /config/
fi


# Configure vhosts.
if [ "x$SERVER_NAMES" != "x" ]; then
    # Use first domain as Apache ServerName.
    SERVER_NAME="${SERVER_NAMES%%,*}"
    sed -i -e "s|ServerName .*|ServerName $SERVER_NAME|" "$HTTPD_PREFIX/conf/custom/httpd-ssl.conf"

    # Replace commas with spaces and set as Apache ServerAlias.
    SERVER_ALIAS="`printf '%s\n' "$SERVER_NAMES" | tr ',' ' '`"
    sed -i -e "/ServerName/a\ \ ServerAlias $SERVER_ALIAS" "$HTTPD_PREFIX/conf/custom/httpd-ssl.conf"
fi

# Set password hash
if [ "x$USERNAME" != "x" ] && [ "x$PASSWORD" != "x" ]; then
	htpasswd -B -b -c "$HTTPD_PREFIX/user.passwd" $USERNAME $PASSWORD
else
	htpasswd -B -b -c "$HTTPD_PREFIX/user.passwd" "webdav" "webdav"
fi

# If not exists, generate a self-signed certificate pair.
if [ ! -e /key.pem ] || [ ! -e /cert.pem ]; then
	openssl req -x509 -newkey rsa:4096 -days 9999 -nodes \
	  -keyout /usr/local/apache2/conf/server.key \
	  -out /usr/local/apache2/conf/server.crt \
	  -subj "/CN=${SERVER_NAME:-selfsigned}"
else
	ln -sfn /key.pem /usr/local/apache2/conf/server.key
	ln -sfn /cert.pem /usr/local/apache2/conf/server.crt
fi


exec "$@"
