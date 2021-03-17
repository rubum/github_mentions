defmodule GithubMentionsWeb.PageController do
  use GithubMentionsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
