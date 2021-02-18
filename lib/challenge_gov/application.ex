defmodule ChallengeGov.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: ChallengeGov.PubSub},
      ChallengeGov.Repo,
      {Finch, name: ChallengeGov.HTTPClient},
      Web.Endpoint,
      ChallengeGov.Scheduler,
      ChallengeGov.Telemetry,
      {Oban, oban_config()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChallengeGov.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Web.Endpoint.config_change(changed, removed)
    :ok
  end

  defp oban_config do
    Application.get_env(:challenge_gov, Oban)
  end
end
