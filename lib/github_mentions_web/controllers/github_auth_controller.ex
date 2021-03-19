defmodule GithubMentionsWeb.GithubAuthController do
    use GithubMentionsWeb, :controller
  
    def index(conn, %{"code" => code}) do
        # get_access_token(code)

        case ElixirAuthGithub.github_auth(code) do
          {:ok, profile} ->
            IO.inspect(profile, label: "profile ")

            conn
            |> put_view(GithubMentionsWeb.PageView)
            |> render(:profile, profile: profile)

          {:error, _message} -> 
            conn
            |> redirect(to: Routes.page_path(conn, :index))
        end
    end

    defp get_access_token(code) do
        access_url = "https://github.com/login/oauth/access_token?"

        [client_id: gclient_id, client_secret: gclient_secret] = 
            Application.get_env(:github_mentions, :github_api_keys)

        req_body = 
            URI.encode_query(%{
                client_id: gclient_id, 
                client_secret: gclient_secret, 
                code: code,
                redirect_uri: "http://localhost:4000/auth/github/callback"
            })

        headers = %{"Content-Type" => "application/x-www-form-urlencoded"}

        case HTTPoison.post(access_url, req_body, headers) do
            {:ok, %HTTPoison.Response{body: access_token}} -> 
                IO.inspect(access_token, label: "access_token ")

            {:error, message} ->
                IO.inspect(message, label: "Error ")
        end
    end
  end