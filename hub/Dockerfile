FROM centos:centos6
MAINTAINER John Casey <jcasey@redhat.com>

VOLUME /koji-clients

RUN yum -y update
RUN yum -y install git yum-utils tar bzip make patch

# TODO: Enable different versions of Koji instead of the master branch
RUN git clone https://git.fedorahosted.org/git/koji /opt/koji

ADD etc/pki/ /etc/pki/
ADD bin/ /usr/local/bin/

RUN chmod +x /usr/local/bin/*
RUN /usr/local/bin/setup.sh
RUN /usr/local/bin/usercert.sh kojiadmin
RUN /usr/local/bin/usercert.sh testuser

CMD /bin/bash
