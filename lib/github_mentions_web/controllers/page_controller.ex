defmodule GithubMentionsWeb.PageController do
  use GithubMentionsWeb, :controller

  alias GithubMentions.Event
  alias GithubMentions.User

  def index(conn, _params) do
    base_auth_url = "https://github.com/login/oauth/authorize?"
    
    [client_id: github_client_id, client_secret: _] = Application.get_env(:github_mentions, :github_api_keys)
    oauth_url =  base_auth_url <> "client_id=#{github_client_id}" # <> "&scope=user%20user:email"

    render(conn, "index.html", oauth_github_url: oauth_url)
  end

  def profile(conn, _params) do
    users = User.all()
    user_profile = User.get_profile()

    render(conn, "profile.html", profile: user_profile, users: users)
  end

  def events(conn, _params) do
    render(conn, "events.html", events: Event.get_pr_events())
  end

  def update_user(conn, %{"repo_name" => repo_name, "user_id" => id}) do
      GithubMentions.Repo.transaction(fn ->
        # we reset the user whose mentions we're tracking
        User.reset_mentions()
  
        User.get_by_id(id)
        |> User.create_or_update(%{"repo_name" => repo_name, "show_mentions" => true})
      end)

      {users, user_profile} = { User.all(), User.get_profile() }
      render(conn, "profile.html", profile: user_profile, users: users)
  end
end
