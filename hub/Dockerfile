FROM centos:centos6
MAINTAINER John Casey <jcasey@redhat.com>

#RUN sed -i '/excludedocs/d' /etc/rpm/macros.imgcreate
RUN sed -i '/nodocs/d' /etc/yum.conf

VOLUME ["/opt/koji-clients", "/opt/koji"]

RUN yum -y update
RUN yum -y install git yum-utils tar bzip2 rpm-build make patch httpd mod_wsgi mod_ssl lsof python-simplejson PyGreSQL pyOpenSSL python-krbV python-qpid python-saslwrapper saslwrapper postgresql

ADD etc/ /etc/
ADD bin/ /usr/local/bin/
ADD root/ /root/

RUN chmod 600 /root/.pgpass
RUN chmod +x /usr/local/bin/*

RUN mkdir -p /mnt/koji/{packages,repos,work,scratch}
RUN chown apache.apache /mnt/koji/*

EXPOSE 80 443

ENTRYPOINT /usr/local/bin/entrypoint.sh
