FROM ruby:2.6.1-stretch
LABEL "com.github.actions.name"="SkySQL" \
      "com.github.actions.description"="SkySQL Client" \
      "com.github.actions.icon"="database" \
      "com.github.actions.color"="blue"

RUN bundle config --global frozen 1

WORKDIR /usr/src/app


COPY . .
RUN bundle install &&\
    rake install:local