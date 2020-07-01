defmodule ExPathom.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  use Boundary, deps: [ExPathom, ExPathomWeb]

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ExPathomWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ExPathom.PubSub},
      # Start the Endpoint (http/https)
      ExPathomWeb.Endpoint
      # Start a worker by calling: ExPathom.Worker.start_link(arg)
      # {ExPathom.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExPathom.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExPathomWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
