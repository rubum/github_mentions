defmodule GithubMentions.Processor do
    @moduledoc """
    Processing of Github mentions is done in this module.
    
    """

    use GenServer
    require Logger
    alias GithubMentions.User

    def init([]) do 
        Logger.info("Starting #{__MODULE__} server")
        {:ok, []}
    end

    def start_link(state) do
        GenServer.start_link(__MODULE__, state, name: __MODULE__)
    end

    def process(data) do          
        case User.get_tracked() do
            nil -> 
                {:reply, %{pr_events: [], comment_events: []}}

            %{name: name, repo_name: repo} -> 
                handle_call(:process, nil, {data, name, repo})
        end
    end

    defp handle_call(:process, _from, {data, user_name, repo_name}) do
        {:reply, 
            Task.async_stream(data, &filter(&1, "PullRequestEvent", repo_name, user_name))
            |> process_filtered_events()
        }
    end

    defp filter(event, type, repo_name, user_name) do
        filter_by_type(event, type)
        |> filter_by_repo(repo_name)
        |> filter_by_user(user_name)
    end

    defp filter_by_type(event, type) do
        if (event["type"] == type), do: event
    end

    defp filter_by_repo(event, name) do
        if event && get_in(event, ["repo", "name"]) |> String.match?(~r/#{name}/), do: event
    end

    defp filter_by_user(event, name) do
        if event && get_in(event, ["payload", "pull_request", "body"]) |> String.match?(~r/#{name}/), 
        do: event
    end

    defp process_filtered_events(events) do
        now = NaiveDateTime.utc_now |> NaiveDateTime.truncate(:second)
        Enum.reduce(events, [], fn {:ok, pr}, acc -> 
            entry = 
                if not is_nil(pr), do:
                %{
                    type: "pull_request",
                    created_by: get_in(pr, ["actor", "login"]),
                    is_open: is_nil(pr["closed_at"]),
                    content: get_in(pr,["payload", "pull_request", "body"]),
                    inserted_at: now,
                    updated_at: now
                }

            List.insert_at(acc, -1,  entry)
        end)
        |> Enum.filter(& !is_nil(&1))
    end
end