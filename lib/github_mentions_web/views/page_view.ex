defmodule GithubMentionsWeb.PageView do
  use GithubMentionsWeb, :view

  def get(atom, string, nil), do: ""
  def get(atom, string, data) do
    Map.get(data, atom) || Map.get(data, string)
  end

  def is_signed_in?(conn) do
    now = (DateTime.utc_now() |> DateTime.to_unix)
    
    case Plug.Conn.get_session(conn, :authenticated) do
      {true, id, expiry} when expiry > now -> true
      _ -> false
    end
  end

  def active(conn, page) do
    if conn.request_path == page do
      "font-weight-bold active-page"
    end
  end

  def user_options([]), do: []
  def user_options(users) do
    Enum.reduce(users, [], fn user, acc ->
      List.insert_at(acc, -1, {String.capitalize(user.name), user.id})
    end)
  end

  def is_tracked?(user), do: user.show_mentions

  def tracked_repo([]), do: ""
  def tracked_repo(users) do 
    Enum.find(users, &is_tracked?/1)
    |> Map.get(:repo_name)
  end
end
