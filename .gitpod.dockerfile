FROM elixir:1.10.3

RUN set -xe \
	&& deps='build-essential libssl-dev curl wget make git inotify-tools npm nodejs' \
	&& apt-get update \
	&& apt-get install -y $deps

RUN mix do local.hex --force, local.rebar --force, archive.install hex phx_new --force
