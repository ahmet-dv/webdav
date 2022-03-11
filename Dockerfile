FROM httpd:2.4
ENV HTTPD_PREFIX /usr/local/apache2
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY config/ conf/
RUN set -ex; \
    apt-get update && apt-get install -y openssl; \
	mkdir -p "/dav/data"; \
	mkdir -p "/config"; \
	touch "/dav/DavLock"; \
	chown -R www-data:www-data "/dav";
EXPOSE 443/tcp
ENTRYPOINT ["docker-entrypoint.sh"]
CMD [ "apachectl","-DFOREGROUND" ]

