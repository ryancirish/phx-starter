defmodule Ryancirish.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RyancirishWeb.Telemetry,
      Ryancirish.Repo,
      {DNSCluster, query: Application.get_env(:ryancirish, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Ryancirish.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Ryancirish.Finch},
      # Start a worker by calling: Ryancirish.Worker.start_link(arg)
      # {Ryancirish.Worker, arg},
      # Start to serve requests, typically the last entry
      RyancirishWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ryancirish.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RyancirishWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
