FROM gitpod/workspace-full

RUN brew install elixir
RUN mix do local.hex --force, local.rebar --force, archive.install hex phx_new --force
