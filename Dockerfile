FROM alpine:edge

WORKDIR /usr/src/app
COPY . /usr/src/app

RUN apk --update add ruby ruby-dev ruby-bundler build-base && \
    bundle install -j 4 && \
    bundle exec rake && \
    apk del build-base && rm -fr /usr/share/ri

ENTRYPOINT ["/usr/src/app/bin/codeclimate"]
