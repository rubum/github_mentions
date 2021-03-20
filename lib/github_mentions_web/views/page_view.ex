defmodule GithubMentionsWeb.PageView do
  use GithubMentionsWeb, :view

  def get(atom, string, data) do
    Map.get(data, atom) || Map.get(data, string)
  end

  def is_signed_in() do
    case GithubMentions.User.is_current? do
      result when is_nil(result) -> false
      false -> false
      true -> true
    end
  end
end
