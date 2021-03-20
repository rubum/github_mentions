defmodule GithubMentions.User do
    use Ecto.Schema

    import Ecto.Changeset
    import Ecto.Query, only: [from: 2]

    alias GithubMentions.Repo

    schema "users" do
        field :name, :string
        field :is_current, :boolean, default: true
        field :profile_data, :map
        field :show_mentions, :boolean, default: true
        field :repo_name, :string

        timestamps()
    end

    def changeset(struct, data) do     
        cast(struct, data, [:name, :is_current, :profile_data, :show_mentions, :repo_name])
    end

    def create_or_update(struct \\ %__MODULE__{}, data) do
        changeset(struct, data)
        |> Repo.insert(
            returning: [:id],
            on_conflict: {:replace_all_except, [:id, :inserted_at]},
            conflict_target: :name
        )
    end

    def get_login_name(queryable \\ __MODULE__) do
        from(u in queryable, where: u.show_mentions, select: u.name)
        |> Repo.one
    end

    def get_profile(queryable \\ __MODULE__) do
        from(u in queryable, where: u.is_current, select: u.profile_data)
        |> Repo.one
    end

    def is_current?(queryable \\ __MODULE__) do
        from(u in queryable, select: u.is_current)
        |> Repo.one
    end
end