FROM httpd:2.4
ENV HTTPD_PREFIX /usr/local/apache2
#COPY htdocs/ $HTTPD_PREFIX/htdocs/
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY config/ conf/
RUN set -ex; \
    apt-get update && apt-get install -y openssl; \
    apt-get install -y iputils-ping; \
    apt-get install -y iproute2; \
	mkdir -p "/dav/data"; \
	touch "/dav/DavLock"; \
	chown -R www-data:www-data "/dav";
EXPOSE 443/tcp
ENTRYPOINT ["docker-entrypoint.sh"]
#CMD [ "apachectl","-DFOREGROUND" ]
CMD [ "httpd-foreground" ]
#CMD ["bash","docker-entrypoint.sh"]

