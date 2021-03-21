# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     GithubMentions.Repo.insert!(%GithubMentions.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

defmodule Seeds do
    alias GithubMentions.{User, Event, Repo}

    @user %{
        name: "octocat",
        repo_name: "Spoon-Knife",
        profile_data: %{},
        is_current: false,
        show_mentions: true
    }

    @event %{
        type: "pull_request",
        created_by: "octocat",
        content: "@tester did you got the event?",
        is_open: true
    }

    def run() do
        seed(:user, @user)
        seed(:event, @event)
    end

    defp seed(:user, data) do
        User.changeset(data)
        |> Repo.insert!
    end

    defp seed(:event, data) do
        struct(Event, data)
        |> Repo.insert!
    end
end

Seeds.run()
