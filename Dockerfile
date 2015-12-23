FROM dtheus/rails

USER root
RUN yum -y update; yum -y install ImageMagick postgresql-server postgresql-contrib postgresql-devel; yum clean all
USER web
ENV RAILS_ENV production

WORKDIR /tmp
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN rbenv exec bundle install

ADD . $HOME/app/
WORKDIR $HOME/app/
