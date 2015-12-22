# "ported" by Adam Miller <maxamillion@fedoraproject.org> from
#   https://github.com/fedora-cloud/Fedora-Dockerfiles
#
# Originally written for Fedora-Dockerfiles by
#   scollier <scollier@redhat.com>

FROM centos:centos7
MAINTAINER d-theus(http://github.com/d-theus)
RUN cat /etc/yum/pluginconf.d/fastestmirror.conf  | sed 's/enabled=1/enabled=0/g' > /etc/yum/pluginconf.d/fastestmirror.conf
RUN yum -y update
RUN yum -y install epel-release
RUN yum -y install git-core zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel
RUN yum -y install ImageMagick
RUN yum clean all

RUN useradd web
USER web
RUN git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
ENV PATH ~/.rbenv/bin:$PATH
RUN eval "$(rbenv init -)"
RUN mkdir -p ~/.rbenv/plugins
RUN git clone https://github.com/rbenv/rbenv-vars.git ~/.rbenv/plugins/rbenv-vars
RUN git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bash_profile

RUN rbenv install -v 2.2.0
RUN rbenv global 2.2.0

RUN rbenv exec gem install rails -v 4.1.7

RUN mkdir -p /var/www/homemade

EXPOSE 3000
