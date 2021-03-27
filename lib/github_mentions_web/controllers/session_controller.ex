defmodule GithubMentionsWeb.SessionController do
    use GithubMentionsWeb, :controller

    def login(conn, _params) do
        oauth_url = ElixirAuthGithub.login_url
        render(conn, "index.html", oauth_github_url: oauth_url)
    end

    def logout(conn, _params) do
        GithubMentions.Session.logout_user(conn)
    end
end