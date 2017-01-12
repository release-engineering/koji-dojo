FROM centos:centos7
MAINTAINER John Casey <jcasey@redhat.com>

#RUN sed -i '/excludedocs/d' /etc/rpm/macros.imgcreate
RUN sed -i '/nodocs/d' /etc/yum.conf

RUN yum -y update && \
    yum -y install \
        lsof \
        python-simplejson \
        openssh-server \
        openssh-clients \
    ; yum clean all

ADD bin/ /usr/local/bin/

RUN chmod +x /usr/local/bin/*
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN mkdir /var/run/sshd
RUN echo 'root:mypassword' | chpasswd

ENTRYPOINT /usr/local/bin/entrypoint.sh
