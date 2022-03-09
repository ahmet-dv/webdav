#!/bin/sh
set -ex

CONFIGPATH="/config"

# Set Server Name
if [ ! -z "$SERVER_NAME" ]; then
    sed -i -e "s|ServerName .*|ServerName $SERVER_NAME|" "$HTTPD_PREFIX/conf/custom/httpd-ssl.conf"
fi


# Copy and link config files
if [ ! -e "$CONFIGPATH/httpd.conf" ]; then
	cp $HTTPD_PREFIX/conf/httpd.conf $CONFIGPATH/
fi
if [ ! -e "/config/httpd-dav.conf" ]; then
	cp $HTTPD_PREFIX/conf/extra/httpd-dav.conf $CONFIGPATH/
fi
if [ ! -e "/config/httpd-ssl.conf" ]; then
	cp $HTTPD_PREFIX/conf/extra/httpd-ssl.conf $CONFIGPATH/
fi
ln -sfn $CONFIGPATH/httpd.conf $HTTPD_PREFIX/conf/httpd.conf
ln -sfn $CONFIGPATH/httpd-dav.conf $HTTPD_PREFIX/conf/extra/httpd-dav.conf
ln -sfn $CONFIGPATH/httpd-ssl.conf $HTTPD_PREFIX/conf/extra/httpd-ssl.conf


# Set password hash
if [ ! -z "$USERNAME" ] && [ ! -z "$PASSWORD" ]; then
	htpasswd -B -b -c "$HTTPD_PREFIX/user.passwd" $USERNAME $PASSWORD
else
	htpasswd -B -b -c "$HTTPD_PREFIX/user.passwd" "webdav" "webdav"
fi


# If not exist, generate a self-signed certificate pair.
if [ ! -e $CONFIGPATH/key.pem ] || [ ! -e $CONFIGPATH/cert.pem ]; then
	openssl req -x509 -newkey rsa:4096 -days 9999 -nodes \
	  -keyout $CONFIGPATH/key.pem \
	  -out $CONFIGPATH/cert.pem \
	  -subj "/CN=${SERVER_NAME:-selfsigned}"
else
	ln -sfn $CONFIGPATH/key.pem /usr/local/apache2/conf/server.key
	ln -sfn $CONFIGPATH/cert.pem /usr/local/apache2/conf/server.crt
fi


exec "$@"
