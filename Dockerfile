FROM dtheus/rails

ENV RAILS_ENV production
ENV BUNDLE_WITHOUT test:development
ENV PATH $RBENV_ROOT/shims/:$PATH

WORKDIR /tmp
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN rbenv exec bundle install

ADD . $HOME/app/
USER root
WORKDIR $HOME/app/
RUN bundle exec rake assets:precompile && \
    bundle exec rake assets:clean
RUN chown -R web $HOME/app
USER web

WORKDIR $HOME/app/

VOLUME $HOME/app/public
