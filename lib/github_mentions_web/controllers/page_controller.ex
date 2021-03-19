defmodule GithubMentionsWeb.PageController do
  use GithubMentionsWeb, :controller

  def index(conn, _params) do
    base_auth_url = "https://github.com/login/oauth/authorize?"
    
    [client_id: github_client_id, client_secret: _] = Application.get_env(:github_mentions, :github_api_keys)
    oauth_url =  base_auth_url <> "client_id=#{github_client_id}" #<> "&scope=user%20user:email"

    render(conn, "index.html", [oauth_github_url: oauth_url])
  end

  def profile(conn, _params) do
    render(conn, "profile.html")
  end

  def events(conn, _params) do
    render(conn, "events.html")
  end
end
