FROM centos:centos6
MAINTAINER John Casey <jcasey@redhat.com>

#VOLUME /koji-clients

RUN yum -y update
RUN yum -y install git yum-utils tar bzip2 rpm-build make patch httpd mod_wsgi mod_ssl lsof python-simplejson

ADD etc/ /etc/
ADD bin/ /usr/local/bin/

RUN chmod +x /usr/local/bin/*
RUN /usr/local/bin/setup.sh

CMD /bin/bash
