defmodule GithubMentions.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table "users" do
      add :name, :string
      add :is_current, :boolean, default: true
      add :profile_data, :map
      add :show_mentions, :boolean, default: true
      add :repo_name, :string

      timestamps()
    end

    create_if_not_exists unique_index("users", [:name])
  end
end
