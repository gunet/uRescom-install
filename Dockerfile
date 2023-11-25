FROM ghcr.io/gunet/urescom-base

LABEL gr.gunet.uRescom.maintainer="info@gunet.gr"
LABEL org.opencontainers.image.source="https://github.com/gunet/uRescom-install"
LABEL org.opencontainers.image.description="GUNet uResCom"

COPY institution/certs/privkey.* /etc/ssl/private/
COPY institution/certs/server.crt /etc/ssl/certs/
COPY institution/config/_config.php ${URESCOM_BASE}/
COPY institution/config/acl.conf /etc/apache2/

RUN INSTALL_DATE=$(date +%Y-%m-%d) && \
    sed -i'' -e "s#INSTALLATION_DATE#${INSTALL_DATE}#" ${URESCOM_BASE}/_config.php

ENV PRIVKEY_PASSPHRASE=1234
ENV PROXY_PROTOCOL=Off
ENV TZ=Europe/Athens

ENV URESCOM_SITE=https://localhost
ENV URESCOM_DOMAIN=gunet.gr
ENV URESCOM_DEBUG=no

ENV URESCOM_SQL_USER=user
ENV URESCOM_SQL_PASSWORD=secret
ENV URESCOM_SQL_HOST=mssql
ENV URESCOM_SQL_DATABASE=urescom
# Set to yes to automatically trust any certificate presented by the
# MSSQL server
ENV URESCOM_SQL_TRUST_CERT=no

ENV URESCOM_MARIADB_HOST=db
ENV URESCOM_MARIADB_DATABASE=urescom
ENV URESCOM_MARIADB_USER=urescom
ENV URESCOM_MARIADB_PASSWORD=secret

ENV URESCOM_CAS_HOSTNAME=localhost
ENV URESCOM_CAS_CONTEXT=./
ENV URESCOM_CAS_PORT=443

WORKDIR ${URESCOM_BASE}

EXPOSE 443

ENTRYPOINT [ "/usr/local/bin/docker-php-entrypoint" ]

CMD [ "/usr/bin/supervisord" ]
