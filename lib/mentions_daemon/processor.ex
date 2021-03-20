defmodule GithubMentions.Processor do
    @moduledoc """
    Processing of Github mentions is done in this module.
    
    """

    use GenServer

    require Logger

    def init([]) do 
        Logger.info("Starting #{__MODULE__} server")
        {:ok, []}
    end

    def start_link(state) do
        GenServer.start_link(__MODULE__, state, name: __MODULE__)
    end

    # def process({"message":message}), do: IO.inspect(message, label: "message ")
    def process(data) do        
        user_name = "rubum"
        repo_name = "comly"

        user_mention_prs = 
            case Jason.decode!(data) do
                %{"documentation_url" => _docs, "message" => message} ->
                    Logger.error(message)
                    []

                data ->
                    filter_pr_events(data)
                    |> filter_repo_prs(repo_name)
                    |> filter_user_mentioned_prs(user_name)
                    |> save_filtered_events()
            end

        handle_call(:process, nil, %{pr_events: user_mention_prs, comment_events: []})
    end

    def handle_call(:process, _from, data) do
        # save_events(data)
        {:reply, data}
    end

    defp filter_pr_events(events) do
        Enum.filter(events, fn event -> event["type"] == "PullRequestEvent" end)
    end

    defp filter_repo_prs(events, repo_name) do
        Enum.filter(events, &get_in(&1, ["repo", "name"]) |> String.match?(~r/#{repo_name}/))
    end

    defp filter_user_mentioned_prs(events, user_name) do
        Enum.filter(events, &get_in(&1, ["payload", "pull_request", "body"]) |> String.match?(~r/#{user_name}/))
    end

    defp save_filtered_events(data) do
        now = NaiveDateTime.utc_now |> NaiveDateTime.truncate(:second)
        entries = 
            Enum.reduce(data, [], fn pr, acc -> 
                entry = %{
                    type: "pull_request",
                    created_by: get_in(pr, ["actor", "login"]),
                    is_open: is_nil(pr["closed_at"]),
                    content: get_in(pr,["payload", "pull_request", "body"]),
                    inserted_at: now,
                    updated_at: now
                }

                List.insert_at(acc, -1,  entry)
            end)

        GithubMentions.Event.save(entries)

        Logger.info("Saved events")
        entries
    end
end