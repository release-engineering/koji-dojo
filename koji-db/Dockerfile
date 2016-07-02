FROM postgres:9.4
MAINTAINER Luiz Carvalho <lucarval@redhat.com>

RUN \
    apt-get update && \
    apt-get install -y curl && \
    apt-get clean

# Location for init scripts executed only during DB
# initialization. Scripts will be executed in
# alphabetical order
ADD sql-init/ /docker-entrypoint-initdb.d/

RUN curl https://pagure.io/koji/raw/master/f/docs/schema.sql \
        -o /docker-entrypoint-initdb.d/00-schema.sql

