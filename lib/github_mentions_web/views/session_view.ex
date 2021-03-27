defmodule GithubMentionsWeb.SessionView do
    use GithubMentionsWeb, :view

    def is_signed_in?(conn) do
        now = (DateTime.utc_now() |> DateTime.to_unix)
        
        case Plug.Conn.get_session(conn, :authenticated) do
          {true, id, expiry} when expiry > now -> true
          _ -> false
        end
    end
end