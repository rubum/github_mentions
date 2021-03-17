defmodule GithubMentions.Repo do
  use Ecto.Repo,
    otp_app: :github_mentions,
    adapter: Ecto.Adapters.Postgres
end
