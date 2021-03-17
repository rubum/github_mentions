defmodule GithubMentions.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias GithubMentions.ChronSupervisor

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      GithubMentions.Repo,
      # Start the Telemetry supervisor
      GithubMentionsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: GithubMentions.PubSub},
      # Start the Endpoint (http/https)
      GithubMentionsWeb.Endpoint,
      # Start a worker by calling: GithubMentions.Worker.start_link(arg)
      # {GithubMentions.Worker, arg},
      ChronSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GithubMentions.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GithubMentionsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
