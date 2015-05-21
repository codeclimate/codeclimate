FROM codeclimate/alpine-ruby:0.0.1

WORKDIR /usr/src/app
COPY . /usr/src/app

RUN apk --update add build-base && \
    bundle install -j 4 && \
    bundle exec rake && \
    apk del build-base && rm -fr /usr/share/ri

ENTRYPOINT ["/usr/src/app/bin/codeclimate"]
