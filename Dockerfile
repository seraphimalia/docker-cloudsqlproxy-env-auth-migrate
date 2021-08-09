# use latest flyway
FROM busybox

RUN mkdir -p /usr/local/sbin/
RUN wget "https://storage.googleapis.com/cloudsql-proxy/v1.21.0/cloud_sql_proxy.linux.amd64" -O /usr/local/sbin/cloud_sql_proxy
RUN chmod +x /usr/local/sbin/cloud_sql_proxy

COPY start-proxy.sh /usr/local/sbin/
RUN chmod +x /usr/local/sbin/start-proxy.sh

WORKDIR /usr/local/sbin/

ENTRYPOINT ["start-proxy.sh"]
