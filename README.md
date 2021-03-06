**EXPERIMENTAL, INCOMPLETE, CHANGING RAPIDLY, USE AT YOUR OWN RISK**

# ExPathom

[![Tests](https://github.com/naramore/ex_pathom/workflows/test/badge.svg)](https://github.com/naramore/ex_pathom/actions)
[![Analyses](https://github.com/naramore/ex_pathom/workflows/check/badge.svg)](https://github.com/naramore/ex_pathom/actions)
[![codecov](https://codecov.io/gh/naramore/ex_pathom/branch/master/graph/badge.svg?token=)](https://codecov.io/gh/naramore/ex_pathom)
[![Dependabot](https://api.dependabot.com/badges/status?host=github&repo=naramore/ex_pathom)](https://dependabot.com)

[Pathom](https://github.com/wilkerlucio/pathom) in Elixir.

## Getting Started via Gitpod

  * Open in Gitpod: https://gitpod.io/#https://github.com/naramore/ex_pathom
  * Login w/ GitHub (requires GitHub account) & wait for your dev environment to load...
  * Run in Terminal: `mix setup && iex -S mix phx.server`
  * Wait for deps + compile...
  * Notifications should have appeared: open port `4000` in browser (or preview).
  * *(Optional)* Click on the `LiveDashboard` link (in the top right corner)
  * ...
  * Profit

## Learn more

  * Elixir: https://elixir-lang.org/
  * Elixir Docs: https://hexdocs.pm/elixir/Kernel.html
  * Erlang Docs: https://erlang.org/doc/search/
  * Phoenix: https://www.phoenixframework.org/
  * Elixir Forum: https://elixirforum.com/
  * Pathom: https://github.com/wilkerlucio/pathom
  * Gitpod: https://www.gitpod.io/
  
# TODO

- [ ] https support in gitpod: https://github.com/gitpod-io/gitpod/issues/1594
- [ ] figure out how to make InchCI work? maybe?
- [ ] add elixir-ls & codetour to .gitpod.yml
- [ ] configure swarm & libcluster
- [ ] update dialyzer, credo, & sobelow to ignore less & fix the underlying problems
- [ ] liveview :digraph viewer + editor:
  - [ ] search, filter, pathing (via highlighting)
  - [ ] hover on edge highlights all edges in same resolver
  - [ ] depth + direct/indirect inputs/outputs
  - [ ] full graph, resolver(s) focus, attribute(s) focus
  - [ ] list of: attributes, resolvers, edges
  - [ ] detail views: attribute, resolver
  - [ ] visual pathing + construct execution graph
- [ ] pathom resolvers:
  - [ ] middleware and/or interceptors
  - [ ] transformers
  - [ ] batching
  - [ ] caching
  - [ ] tracing
- [ ] liveview pathom inspector / explorer:
  - [ ] endpoint, autocomplete, tabs, tracing, planner
  - [ ] prettify, history, settings, copy curl, share
  - [ ] syntax checker (i.e. syntax highlighting & yellow / red underlining + error messages)
  - [ ] graph explorer:
    - [ ] attribute search + docs + type
    - [ ] resolver search + docs
    - [ ] *above* w/o editing
- [ ] stream_data:
  - [ ] digraph generators
  - [ ] request (i.e. EQL AST) generators
    - [ ] uses graph to create
    - [ ] generate once -> encode to file?
- [ ] performance test pathing:
  - [ ] github action? on PR only?
  - [ ] requests:
    - [ ] count: 100 - 1_000_000
    - [ ] input: 0 - 10
    - [ ] depth: 1 - 30
    - [ ] breadth: 1 - 100
  - [ ] create the 'full' XAPI graph to test against
  - [ ] graph:
    - [ ] attribute size: 10 - 500_000
    - [ ] resolver size: 10 - 10_000
    - [ ] global ratio: 0.0 - 50.0
    - [ ] multi-input ratio: 0.0 - 0.75
    - [ ] average input/output ratio: 1.0 - 50.0
    - [ ] average output hierarchy ratio: 0.0 - 0.75
    - [ ] average output hierarchy depth: 1 - 10
  - [ ] average output multiplicity: 10 - 1_000_000
  - [ ] max_concurrency: 1 - 10_000 / per scheduler
  - [ ] compare to 'previous' commit
- [ ] performance test resolving...
- [ ] add more telemetry? (e.g. prometheus, spandex, sentry)
