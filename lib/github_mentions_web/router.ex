defmodule GithubMentionsWeb.Router do
  use GithubMentionsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GithubMentionsWeb do
    pipe_through :browser

    get "/auth/github/callback", GithubAuthController, :index
    get "/", PageController, :index
    get "/profile", PageController, :profile
    get "/events", PageController, :events
    post "/update-user", PageController, :update_user
  end

  # Other scopes may use custom stacks.
  # scope "/api", GithubMentionsWeb do
  #   pipe_through :api
  # end
end
