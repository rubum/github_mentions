defmodule GithubMentions.Poller do
    @moduledoc """
    Polling of Github mentions is provided in this module.

    """

    use GenServer

    alias GithubMentions.Processor

    def init([]) do
        IO.puts("Starting server ...")
        pr_mentions = %{}
        comment_mentions = %{}
        send(self(), :poll)
        {:ok, {pr_mentions, comment_mentions}}
    end

    def start_link(state) do
        GenServer.start_link(__MODULE__, state, name: __MODULE__)
    end
    
    def handle_info(:poll, state) do
        url = "https://api.github.com/notifications"
        auth_url = "https://api.github.com/users/rubum/events"

        case poll_mentions(auth_url) do
            {:ok, data} -> 
                {_, updated_state} = Processor.process(data)
                poll_after(60_000)
                IO.puts("Got data. Polling in #{60_000} seconds")
                {:noreply, updated_state}

            {:error, _} -> 
                poll_after(60_000)
                IO.puts("No data. Polling in #{60_000} seconds")
                {:noreply, state}
        end
    end

    def poll_mentions(url) do
        HTTPoison.get(url)
    end

    def poll_after(time \\ 60_000) do
        Process.send_after(self(), :poll, time)
    end
end