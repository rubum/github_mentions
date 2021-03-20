defmodule GithubMentions.Repo.Migrations.AddEventsTable do
  use Ecto.Migration

  def change do
    create table "events" do
      add :type, :string
      add :created_by, :string
      add :is_open, :boolean
      add :content, :text

      timestamps()
    end
  end
end
