FROM alpine:3.16.0

ARG TARGETARCH

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
      wget && \
      bundle install -j 4 && \
      apk del build-base && \
      rm -fr /usr/share/ri

RUN ARCH="$TARGETARCH"; \
    if [ "$ARCH" = "arm64" ]; then ARCH=aarch64; \
    elif [ "$ARCH" = "amd64" ]; then ARCH=x86_64; fi; \
    wget -q -O /tmp/docker.tgz \
    https://download.docker.com/linux/static/stable/$ARCH/docker-17.12.1-ce.tgz && \
    tar -C /tmp -xzvf /tmp/docker.tgz && \
    mv /tmp/docker/docker /bin/docker && \
    chmod +x /bin/docker && \
    rm -rf /tmp/docker*

COPY . /usr/src/app

VOLUME /code
WORKDIR /code
ENTRYPOINT ["/usr/src/app/bin/codeclimate"]
