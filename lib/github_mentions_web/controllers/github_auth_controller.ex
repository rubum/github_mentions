defmodule GithubMentionsWeb.GithubAuthController do
    use GithubMentionsWeb, :controller

    alias GithubMentions.User
    alias GithubMentions.Repo
  
    def index(conn, %{"code" => code}) do  
        case ElixirAuthGithub.github_auth(code) do
            {:ok, profile} ->
                params = map_user_data(profile)

                {:ok, {:ok, user}} = 
                    Repo.transaction(fn -> 
                        User.reset_mentions()
                        User.create_or_update(params)
                    end)

                expiry_dt = (DateTime.utc_now() |> DateTime.to_unix) + 60 # timeout

                put_session(conn, :authenticated, {true, user.id, expiry_dt})
                |> put_view(GithubMentionsWeb.PageView)
                |> render(:profile, profile: profile, users: User.all)

            {:error, _message} -> 
                conn
                |> redirect(to: Routes.page_path(conn, :index))
        end
    end

    defp map_user_data(profile) do
        {name, data} = Map.pop(profile, :login)
        %{name: name, profile_data: data}
    end

    # defp fetch_orgs() do
    #     url = "https://api.github.com/user/orgs"
    #     HTTPoison.get(url)
    # end

    # def fetch_and_save_repos(user_profile) do
    #     # if user has no org repos, get user repos
    # end
  end