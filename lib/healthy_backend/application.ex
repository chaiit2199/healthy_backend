defmodule HealthyBackend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias HealthyBackend.DailyGeminiAPI

  @impl true
  def start(_type, _args) do
    gemini_crontab = Application.get_env(:healthy_backend, :GEMINI_CRONTAB) || "0 0 * * *"

    children = [
      # Start the Telemetry supervisor
      HealthyBackendWeb.Telemetry,
      # Start the Ecto repository
      HealthyBackend.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: HealthyBackend.PubSub},
      # Start Finch
      {Finch, name: HealthyBackend.Finch},
      # Start the Endpoint (http/https)
      HealthyBackendWeb.Endpoint,
      %{
        id: "refresh_data",
        start: {SchedEx, :run_every, [DailyGeminiAPI, :work, [], gemini_crontab]}
      },
      # Start a worker by calling: HealthyBackend.Worker.start_link(arg)
      # {HealthyBackend.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HealthyBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HealthyBackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
