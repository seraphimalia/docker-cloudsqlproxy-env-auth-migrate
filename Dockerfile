# use specific flyway version that supports MySQL 5.7
FROM flyway/flyway:7

USER root 

# install App Engine SDK
RUN apt-get -y update
RUN apt-get -y install git netcat wget

RUN mkdir -p /usr/local/sbin/
RUN wget "https://storage.googleapis.com/cloudsql-proxy/v1.21.0/cloud_sql_proxy.linux.amd64" -O /usr/local/sbin/cloud_sql_proxy
RUN chmod ug+x /usr/local/sbin/cloud_sql_proxy
RUN chown flyway:flyway /usr/local/sbin/cloud_sql_proxy

COPY db-migrate.sh /flyway
COPY startup-check.sh /flyway

RUN chmod ug+rx db-migrate.sh startup-check.sh
RUN chown flyway:flyway db-migrate.sh startup-check.sh

WORKDIR /flyway
# Change to the flyway user
USER flyway

ENTRYPOINT ["db-migrate.sh"]
