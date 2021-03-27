defmodule GithubMentions.Session do
    import Plug.Conn
    import Phoenix.Controller

    alias GithubMentionsWeb.Router.Helpers

    def authenticate(conn, _opts) do
        now = (DateTime.utc_now() |> DateTime.to_unix)

        case get_session(conn, :authenticated) do
            {true, id, expiry} when expiry > now ->  
                assign(conn, :current_user, GithubMentions.User.get_by_id(id))
            _ -> 
                logout_user(conn)  
        end
    end

    def logout_user(conn) do
        conn
        |> clear_session()
        |> configure_session([:renew])
        |> redirect(to: Helpers.session_path(conn, :login))
        |> halt()
    end
end