FROM dtheus/rails

USER root
RUN yum -y update; yum -y install ImageMagick postgresql-server postgresql-contrib postgresql-devel; yum clean all
USER web
ADD . $HOME/app/
ENV RAILS_ENV production
RUN rbenv exec bundle install
