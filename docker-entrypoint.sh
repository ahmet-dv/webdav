#!/bin/sh
set -ex

CONFIGPATH="/config"

# Copy and link config files
if [ ! -e "$CONFIGPATH/httpd.conf" ]; then
	cp $HTTPD_PREFIX/conf/custom/httpd.conf $CONFIGPATH/
fi
if [ ! -e "/config/httpd-dav.conf" ]; then
	cp $HTTPD_PREFIX/conf/custom/httpd-dav.conf $CONFIGPATH/
fi
if [ ! -e "/config/httpd-ssl.conf" ]; then
	cp $HTTPD_PREFIX/conf/custom/httpd-ssl.conf $CONFIGPATH/
fi
ln -sfn $CONFIGPATH/httpd.conf $HTTPD_PREFIX/conf/httpd.conf


# Set password hash
if [ ! -z "$USERNAME" ] && [ ! -z "$PASSWORD" ]; then
	htpasswd -B -b -c "$HTTPD_PREFIX/user.passwd" $USERNAME $PASSWORD
else
	htpasswd -B -b -c "$HTTPD_PREFIX/user.passwd" "webdav" "webdav"
fi


# Set Server Name
if [ ! -z "$SERVER_NAME" ]; then
    sed -i -e "s|ServerName .*|ServerName $SERVER_NAME|" "$CONFIGPATH/httpd-ssl.conf"
fi


# If doesn't exist, generate a self-signed certificate pair.
if [ ! -e $CONFIGPATH/server.key ] || [ ! -e $CONFIGPATH/server.crt ]; then
	openssl req -x509 -newkey rsa:4096 -days 9999 -nodes \
	  -keyout $CONFIGPATH/server.key \
	  -out $CONFIGPATH/server.crt \
	  -subj "/CN=${SERVER_NAME:-selfsigned}"
fi
ln -sfn $CONFIGPATH/server.key /usr/local/apache2/conf/server.key
ln -sfn $CONFIGPATH/server.crt /usr/local/apache2/conf/server.crt


exec "$@"
