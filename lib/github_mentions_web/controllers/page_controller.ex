defmodule GithubMentionsWeb.PageController do
  use GithubMentionsWeb, :controller

  alias GithubMentions.Event

  def index(conn, _params) do
    base_auth_url = "https://github.com/login/oauth/authorize?"
    
    [client_id: github_client_id, client_secret: _] = Application.get_env(:github_mentions, :github_api_keys)
    oauth_url =  base_auth_url <> "client_id=#{github_client_id}" # <> "&scope=user%20user:email"

    render(conn, "index.html", [oauth_github_url: oauth_url])
  end

  def profile(conn, _params) do
    user_profile = GithubMentions.User.get_profile()
    render(conn, "profile.html", profile: user_profile)
  end

  def events(conn, _params) do
    render(conn, "events.html", events: Event.get_pr_events())
  end
end
