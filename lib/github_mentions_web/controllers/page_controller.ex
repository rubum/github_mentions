defmodule GithubMentionsWeb.PageController do
  use GithubMentionsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def profile(conn, _params) do
    render(conn, "profile.html")
  end

  def events(conn, _params) do
    render(conn, "events.html")
  end
end
