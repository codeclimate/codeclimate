FROM alpine:3.16.0

WORKDIR /usr/src/app
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
COPY VERSION /usr/src/app/
COPY codeclimate.gemspec /usr/src/app/
ENV CODECLIMATE_DOCKER=1 BUNDLE_SILENCE_ROOT_WARNING=1

RUN apk --no-cache upgrade && \
      apk --no-cache --update add \
      build-base \
      ca-certificates \
      git \
      openssh-client \
      openssl \
      ruby \
      ruby-bigdecimal \
      ruby-bundler \
      ruby-dev \
      wget  \
      podman  \
      slirp4netns  \
      fuse-overlayfs && \
      bundle install -j 4 && \
      apk del build-base && \
      rm -fr /usr/share/ri

COPY . /usr/src/app

VOLUME /code
WORKDIR /code
ENTRYPOINT ["/usr/src/app/bin/codeclimate"]
