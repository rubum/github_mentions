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

    def process(data, event_type) do   
        case event_type do
            :pull_requests -> handle_call(:process_user_pull_requests, nil, data)
            :comments -> handle_call(:process_org_comments, nil, data)
        end
    end

    def handle_call(:process_user_pull_requests, _from, {data, user_name, repo_name}) do
        user_mention_prs = do_handle(data, :user)
        {:reply, %{pr_events: user_mention_prs, comment_events: []}}
    end

    
    def handle_call(:process_org_comments, _from, {data, user_name, repo_name}) do
        org_comment_events = do_handle(data)
        {:reply, %{pr_events: [], comment_events: org_comment_events}}
    end
    
    defp do_handle(data, owner) do
        case owner do
            :org -> Org.get_tracked() |> filter(data)
            :user -> User.get_tracked() |> filter(data)
        end
    end

    defp filter(nil, _), do: []
    defp filter(events, %{name: user_name, repo_name: repo_name}) do
        filter_by_type(events, "PullRequestEvent")
        |> filter_by_repo(repo_name)
        |> filter_by_user("pull_request", user_name)
        |> save_filtered_events("pull_request")
    end

    defp filter_events(events, %{org_name: _org_name}) do
        Enum.map(["CommitCommentEvent", "IssueCommentEvent", "PullRequestReviewCommentEvent"], 
            &filter_by_type(events, &1)
        )
        |> save_filtered_events("comment")
    end

    defp filter_by_type(events, type) do
        Enum.filter(events, fn event -> event["type"] == type end)
    end

    def filter_by_org(events, org) do
        # get all comment events for org
    end

    defp filter_by_repo(events, repo_name) do
        Enum.filter(events, &get_in(&1, ["repo", "name"]) |> String.match?(~r/#{repo_name}/))
    end

    defp filter_by_user(events, type, user_name) do
        Enum.filter(events, 
            &get_in(&1, ["payload", trans_type, "body"]) 
            |> String.match?(~r/#{user_name}/)
        )
        |> IO.inspect(label: "#{trans_type} events for #{user_name}")
    end

    defp transform(type) do
        cond do
            String.match?(type, ~r/Comment/) -> "comment"
            true -> "pull_request"
        end
    end

    defp save_filtered_events(data, type) do
        now = NaiveDateTime.utc_now |> NaiveDateTime.truncate(:second)
        entries = 
            Enum.reduce(data, [], fn pr, acc -> 
                entry = %{
                    type: trans_type,
                    created_by: get_in(pr, ["actor", "login"]),
                    is_open: is_nil(pr["closed_at"]),
                    content: get_in(pr,["payload", "pull_request", "body"]),
                    inserted_at: now,
                    updated_at: now
                }

                List.insert_at(acc, -1,  entry)
            end)

        GithubMentions.Event.save(entries)
        entries
    end
end