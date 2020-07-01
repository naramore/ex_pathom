FROM elixir:1.10.3

RUN set -xe \
  && deps='build-essential libssl-dev curl wget make git inotify-tools' \
  && apt-get update \
  && apt-get install -y $deps \
  && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  && apt-get install -y nodejs

RUN mix do local.hex --force, local.rebar --force, archive.install hex phx_new --force
