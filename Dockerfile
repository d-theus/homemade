FROM dtheus/rails

ENV RAILS_ENV production
ENV BUNDLE_WITHOUT test:development
ENV PATH $RBENV_DIR/shims:$PATH

WORKDIR /tmp
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN rbenv exec bundle install

ADD . $HOME/app/
WORKDIR $HOME/app/
CMD /bin/bash
