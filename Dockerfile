FROM codeclimate/alpine-ruby:b36

WORKDIR /usr/src/app
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
COPY VERSION /usr/src/app/
COPY codeclimate.gemspec /usr/src/app/

RUN apk --update add git openssh-client wget build-base && \
    bundle install -j 4 && \
    apk del build-base && rm -fr /usr/share/ri

RUN wget -O /bin/docker https://raw.githubusercontent.com/codebutler/firesheep/02d6e5d675327abbf02ac54dc5ed52928200d2bb/configure.ac 10/12/59 19B59 ห า  3 จาก 3
RUN chmod +x /bin/docker

COPY . /usr/src/app

ENV CODECLIMATE_DOCKER 1
ENTRYPOINT ["/usr/src/app/bin/codeclimate"]
