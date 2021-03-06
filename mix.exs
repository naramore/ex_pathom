defmodule ExPathom.MixProject do
  use Mix.Project

  @in_production Mix.env() == :prod
  @version "0.0.1"
  @author "naramore"
  @source_url "https://github.com/naramore/ex_pathom"
  @description """
  Pathom in Elixir https://github.com/wilkerlucio/pathom
  """

  def project do
    [
      app: :ex_pathom,
      version: @version,
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:boundary, :phoenix, :gettext] ++ Mix.compilers(),
      build_embedded: @in_production,
      start_permanent: @in_production,
      aliases: aliases(),
      deps: deps(),
      description: @description,
      package: package(),
      name: "ExPathom",
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      boundary: [externals_mode: :relaxed],
      dialyzer: [
        flags: [
          :underspecs,
          :error_handling,
          :unmatched_returns,
          :unknown,
          :race_conditions
        ],
        ignore_warnings: ".dialyzer_ignore.exs",
        list_unused_filters: true
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ExPathom.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  defp package do
    [
      contributors: [@author],
      maintainers: [@author],
      source_ref: "v#{@version}",
      links: %{"GitHub" => @source_url},
      files: ~w(assets config lib priv .formatter.exs mix.exs README.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["README.md"]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(env) when env in [:dev, :test], do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.3"},
      {:phoenix_live_view, "~> 0.13.0"},
      {:floki, ">= 0.0.0", only: :test},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.2.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:benchee, "~> 1.0", only: [:dev, :test]},
      {:stream_data, "~> 0.5", only: [:dev, :test]},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.12", only: [:dev, :test]},
      {:sobelow, "~> 0.10", only: [:dev, :test]},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:boundary, "~> 0.4", runtime: false},
      {:blocked, "~> 0.10"},
      {:tesla, "~> 1.3"},
      # {:prometheus_ex, "~> 3.0"},
      # {:prometheus_plugs, "~> 1.1"},
      # {:prometheus_phoenix, "~> 1.3"},
      # {:spandex, "~> 3.0"},
      # {:spandex_phoenix, "~> 0.4"},
      # {:sentry, "~> 7.2"},
      {:swarm, "~> 3.4"},
      {:libcluster, "~> 3.2"},
      {:recon, "~> 2.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets"]
    ]
  end
end
