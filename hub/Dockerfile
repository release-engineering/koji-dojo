FROM centos:centos6
MAINTAINER John Casey <jcasey@redhat.com>

#RUN sed -i '/excludedocs/d' /etc/rpm/macros.imgcreate
RUN sed -i '/nodocs/d' /etc/yum.conf

VOLUME ["/opt/koji-clients", "/opt/koji"]

RUN yum -y update && \
    yum -y install \
        git \
        yum-utils \
        tar \
        bzip2 \
        rpm-build \
        make \
        patch \
        httpd \
        mod_wsgi \
        mod_ssl \
        lsof \
        python-simplejson \
        PyGreSQL \
        pyOpenSSL \
        python-krbV \
        python-qpid \
        python-saslwrapper \
        saslwrapper \
        postgresql \
        sudo \
        mod_auth_kerb \
        python-cheetah \
        python-markdown \
        python-pygments \
        python-setuptools \
        python-sphinx \
        python-coverage \
        openssh-server \
        wget \
    ; yum clean all

ADD etc/ /etc/
ADD bin/ /usr/local/bin/
ADD root/ /root/

RUN chmod 600 /root/.pgpass
RUN chmod +x /usr/local/bin/*

ADD cgi/*.py /var/www/cgi-bin/
RUN chmod o+rx /var/log /var/log/httpd
RUN chmod +x /var/www/cgi-bin/*.py
RUN chmod o+rwx /var/www/html
RUN chmod -R o+rx /etc/httpd

RUN mkdir -p /mnt/koji/{packages,repos,work,scratch}
RUN chown apache.apache /mnt/koji/*
RUN echo 'root:mypassword' | chpasswd

EXPOSE 22 80 443

ENTRYPOINT /usr/local/bin/entrypoint.sh
