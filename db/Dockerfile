FROM postgres:9.4
MAINTAINER John Casey <jcasey@redhat.com>

ENV POSTGRES_DB 'koji'
ENV POSTGRES_USER 'koji'
ENV POSTGRES_PASSWORD 'mypassword'

RUN apt-get update -y
RUN apt-get install -y apt-utils git

# TODO: Enable different versions of Koji instead of the master branch
RUN git clone https://git.fedorahosted.org/git/koji /opt/koji

RUN cp /opt/koji/docs/schema.sql /docker-entrypoint-initdb.d/0001-schema.sql
RUN cp /opt/koji/docs/schema-update-cgen.sql /docker-entrypoint-initdb.d/0002-schema-update-cgen.sql


