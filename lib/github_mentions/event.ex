defmodule GithubMentions.Event do
    use Ecto.Schema

    require Logger

    import Ecto.Query, only: [from: 2]

    alias GithubMentions.Repo

    schema "events" do
        field :type, :string
        field :created_by, :string
        field :is_open, :boolean
        field :content, :string

        timestamps()
    end

    def save(events) do
        {inserted, _} = Repo.insert_all(__MODULE__, events, on_conflict: :nothing)

        inserted > 0 && Logger.info("Saved #{inserted} events")
    end

    def get_pr_events(queryable \\ __MODULE__) do
        from(e in queryable, where: e.type == "pull_request")
        |> Repo.all
    end
end