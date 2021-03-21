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
        {:ok, %{pr_events: [], comment_events: []}}
    end

    def start_link(state) do
        GenServer.start_link(__MODULE__, state, name: __MODULE__)
    end
    
    def handle_info(:poll, state) do
        user_name = GithubMentions.User.get_login_name()
        org_name = "rubum"

        if not is_nil(user_name) do
            "https://api.github.com/users/#{user_name}/events/public"
            |> poll_user_events(state)

            "https://api.github.com/orgs/#{org_name}/events"
            |> poll_org_events(state)
        else
            poll_after(60_000)
            {:noreply, state}
        end
    end

    
    def poll_user_events(url, state), do: do_poll(url, state, :pull_requests)

    def poll_org_events(url, state) , do: do_poll(url, state, :comments]) 

    defp do_poll(url, state, event_type)
        headers = [{"Accept", "application/vnd.github.v3+json"}]
        HTTPoison.get(url, headers)
        |> case do
            {:ok, %{body: data}} -> 
                # process data
                {_, updated_state} = Processor.process(data, event_type)
                
                poll_after(60_000)
                {:noreply, updated_state}

            {:error, _} -> 
                poll_after(60_000)
                {:noreply, state}
        end
    end
    
    def poll_after(time \\ 60_000) do
        Logger.info("Polling in #{time/1000} seconds")
        Process.send_after(self(), :poll, time)
    end
    
    # this sets the github varibles, from app config, that will be used later 
    defp set_github_api_keys() do
        case Application.get_env(:github_mentions, :github_api_keys) do
            nil -> nil

            [client_id: client_id, client_secret: client_secret] ->
                System.put_env("GITHUB_CLIENT_ID", client_id)
                System.put_env("GITHUB_CLIENT_SECRET", client_secret)
                Logger.info("Set Github API keys")
        end        
    end
end