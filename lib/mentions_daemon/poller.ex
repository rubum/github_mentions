defmodule GithubMentions.Poller do
    @moduledoc """
    Polling of Github mentions is provided in this module.

    """
    use GenServer

    require Logger

    alias GithubMentions.Processor

    def init([]) do
        Logger.info("Starting #{__MODULE__} server")
        set_github_api_keys()

        send(self(), :poll)
        {:ok, {%{}, %{}}}
    end

    def start_link(state) do
        GenServer.start_link(__MODULE__, state, name: __MODULE__)
    end
    
    def handle_info(:poll, state) do
        _url = "https://api.github.com/notifications"
        auth_url = "https://api.github.com/users/rubum/events"

        case poll_mentions(auth_url) do
            {:ok, data} -> 
                {_, updated_state} = Processor.process(data)
                poll_after(60_000)
                Logger.info("Got data. Polling in #{60_000} seconds")
                {:noreply, updated_state}

            {:error, _} -> 
                poll_after(60_000)
                Logger.warn("No data. Polling in #{60_000} seconds")
                {:noreply, state}
        end
    end

    def poll_mentions(url), do: HTTPoison.get(url)

    def poll_after(time \\ 60_000) do
        Process.send_after(self(), :poll, time)
    end

    # this sets the github varibles, from app config, that will be used later 
    defp set_github_api_keys() do
        [client_id: client_id, client_secret: client_secret] = 
            Application.get_env(:github_mentions, :github_api_keys)

        System.put_env("GITHUB_CLIENT_ID", client_id)
        System.put_env("GITHUB_CLIENT_SECRET", client_secret)
        
        Logger.info("Set Github API keys")
    end
end