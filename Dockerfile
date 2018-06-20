FROM ruby:2.2.10-alpine

WORKDIR /usr/src/app
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
COPY VERSION /usr/src/app/
COPY codeclimate.gemspec /usr/src/app/

RUN apk --update add git openssh-client wget build-base && \
    bundle install -j 4 && \
    apk del build-base && rm -fr /usr/share/ri

RUN wget -q -O /tmp/docker.tgz \
    https://download.docker.com/linux/static/stable/x86_64/docker-17.12.1-ce.tgz && \
    tar -C /tmp -xzvf /tmp/docker.tgz && \
    mv /tmp/docker/docker /bin/docker && \
    chmod +x /bin/docker && \
    rm -rf /tmp/docker*

COPY . /usr/src/app

VOLUME /code
WORKDIR /code
ENV CODECLIMATE_DOCKER 1
ENTRYPOINT ["/usr/src/app/bin/codeclimate"]
