FROM centos:centos7
MAINTAINER John Casey <jcasey@redhat.com>

#RUN sed -i '/excludedocs/d' /etc/rpm/macros.imgcreate
RUN sed -i '/nodocs/d' /etc/yum.conf

RUN yum -y update && \
    yum -y install \
        apr \
        apr-util \
        btrfs-progs \
        createrepo \
        createrepo_c \
        createrepo_c-libs \
        cvs \
        distribution-gpg-keys \
        e2fsprogs-libs \
        epel-release \
        freetype \
        git \
        gnutls \
        groff-base \
        initscripts \
        iproute \
        iptables \
        jbigkit-libs \
        less \
        libgnome-keyring \
        libjpeg-turbo \
        libmnl \
        libmodman \
        libnetfilter_conntrack \
        libnfnetlink \
        libproxy \
        libtiff \
        libwebp \
        lsof \
        lzo \
        mock \
        neon \
        nettle \
        openssh-clients \
        openssh-server \
        pakchois \
        perl \
        perl-Carp \
        perl-constant \
        perl-Encode \
        perl-Error \
        perl-Exporter \
        perl-File-Path \
        perl-File-Temp \
        perl-Filter \
        perl-Getopt-Long \
        perl-Git \
        perl-HTTP-Tiny \
        perl-libs \
        perl-macros \
        perl-parent \
        perl-PathTools \
        perl-Pod-Escapes \
        perl-podlators \
        perl-Pod-Perldoc \
        perl-Pod-Simple \
        perl-Pod-Usage \
        perl-Scalar-List-Utils \
        perl-Socket \
        perl-Storable \
        perl-TermReadKey \
        perl-Text-ParseWords \
        perl-threads \
        perl-threads-shared \
        perl-Time-HiRes \
        perl-Time-Local \
        pigz \
        python2-distro \
        python-cheetah \
        python-markdown \
        python-multilib \
        python-pillow \
        python-pygments \
        python-setuptools \
        python-simplejson \
        rsync \
        squashfs-tools \
        subversion \
        subversion-libs \
        systemd-sysv \
        sysvinit-tools \
        trousers \
        usermode \
        wget \
    &&  yum clean all

ADD bin/ /usr/local/bin/

RUN chmod +x /usr/local/bin/*
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN mkdir /var/run/sshd
RUN echo 'root:mypassword' | chpasswd

ENTRYPOINT /usr/local/bin/entrypoint.sh
