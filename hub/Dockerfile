FROM centos:centos7
MAINTAINER John Casey <jcasey@redhat.com>

#RUN sed -i '/excludedocs/d' /etc/rpm/macros.imgcreate
RUN sed -i '/nodocs/d' /etc/yum.conf

VOLUME ["/opt/koji-clients", "/opt/koji"]

RUN yum -y update && \
    yum -y install \
        bzip2 \
        epel-release \
        git \
        httpd \
        libcomps \
        lsof \
        make \
        mod_auth_kerb \
        mod_ssl \
        mod_wsgi \
        openssh-server \
        patch \
        postgresql \
        PyGreSQL \
        pyOpenSSL \
        python-backports \
        python-backports-ssl_match_hostname \
        python-cheetah \
        python-coverage \
        python-dateutil \
        python-kerberos \
        python-krbV \
        python-libcomps \
        python-markdown \
        python-pygments \
        python-qpid \
        python-requests \
        python-requests-kerberos \
        python-saslwrapper \
        python-setuptools \
        python-simplejson \
        python-six \
        python-sphinx \
        python-urllib3 \
        rpm-build \
        saslwrapper \
        sudo \
        tar \
        wget \
        yum-utils \
    && yum clean all

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
