defmodule GithubMentions.ChronSupervisor do
    @moduledoc """
    Supervisor for background polling and processing of Github mentions.

    """

    use Supervisor

    def start_link(opts) do
      Supervisor.start_link(__MODULE__, :ok, opts)
    end

    @impl true
    def init(:ok) do
        children = [
            GithubMentions.Poller,
            GithubMentions.Processor
        ]

        Supervisor.init(children, strategy: :one_for_one)
    end
end