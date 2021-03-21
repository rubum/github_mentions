use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :github_mentions, GithubMentions.Repo,
  username: "postgres",
  password: "postgres",
  database: "github_mentions_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :github_mentions, GithubMentionsWeb.Endpoint,
  http: [port: 4002],
  server: false

# Github API keys
config :github_mentions, :github_api_keys,
  client_id: "Iv1.d5cb44868d25c998",
  client_secret: "86139e43e0e0ef71bdebad5851e08268a456b5fe"

# Print only warnings and errors during test
config :logger, level: :warn
