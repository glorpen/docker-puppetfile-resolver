FROM centos:centos7
LABEL maintainer="Arkadiusz Dzięgiel <arkadiusz.dziegiel@glorpen.pl>"

ARG R10K_VERSION="2.5.5"

RUN yum -y install centos-release-scl-rh \
    && yum -y install rh-ruby24-ruby git \
    && yum clean all

ADD r10k-forge-cache.patch /usr/local/share/

# add r10k to puppet ruby instalation
RUN yum -y install patch \
    && scl enable rh-ruby24 'gem install r10k -v ${R10K_VERSION}' \
    && patch -p1 -d /opt/rh/rh-ruby*/root/usr/local/share/gems/gems/r10k-*/ < /usr/local/share/r10k-forge-cache.patch

ADD r10k.yaml /etc/puppetlabs/r10k/r10k.yaml
ADD resolve.sh /usr/local/bin/puppetfile-resolve

CMD ["/usr/local/bin/puppetfile-resolve"]
