defmodule GithubMentions.ProcessorTest do
    use GithubMentions.DataCase, async: true

    alias GithubMentions.Processor
    alias GithubMentions.Event
    alias GithubMentions.User
    alias GithubMentions.Repo

    @user %{
        name: "rubum",
        repo_name: "comly",
        profile_data: %{},
        is_current: true,
        show_mentions: true
    }

    setup do
        insert_user(@user)

        {:ok, 
            mentions_events: mentions_events(),
            no_mentions: non_mentions_events()
        }
    end

    describe "processing of polled data" do
        
        test "when the specified user is mentioned", %{mentions_events: data} do
            result = Jason.encode!(data) |> Processor.process()

            expected = {:reply, %{pr_events: [%{event_type: "pull_request"}], comment_events: []}}
            assert expected = result
            assert [%Event{type: "pull_request"}] = Event.get_pr_events()
        end

        test "when the specified user is NOT mentioned", %{no_mentions: data} do
            result = Jason.encode!(data) |> Processor.process()
            assert {:reply, %{pr_events: [], comment_events: []}} = result
            assert [] = Event.get_pr_events()
        end
    end

    defp insert_user(data) do 
        Repo.transaction(fn ->
            User.reset_mentions()
            User.create_or_update(data)
        end)
    end

    defp non_mentions_events() do 
        [%{
            "actor" => %{ "login" => "rubum" },
            "payload" => %{
                "action" => "opened",
                "pull_request" => %{
                    "title" => "Test real-time",
                    "body" => "@mike check this one first",
                    "state" => "open",
                }
            },
            "public" => true,
            "repo" => %{ "name" => "rubum/comly" },
            "type" => "PullRequestEvent"
        }]
    end

    defp mentions_events() do
        [%{ "actor" => %{ "login" => "rubum" },
            "payload" => %{
                "action" => "opened",
                "pull_request" => %{
                    "title" => "Test real-time",
                    "body" => "@rubum check the test for real-time",
                    "user" => %{
                      "login" => "rubum",
                      "site_admin" => false,
                      "type" => "User",
                    },
                    "state" => "open",
                }
            },
            "public" => true,
            "repo" => %{ "name" => "rubum/comly" },
            "type" => "PullRequestEvent"
            },
            %{
              "actor" => %{ "login" => "rubum" },
              "payload" => %{
                "action" => "opened",
                "issue" => %{
                  "body" => "@rubum did you work on the real-time integration?",
                  "state" => "open",
                  "title" => "Real-time integration"
                }
              },
              "public" => true,
              "repo" => %{ "name" => "rubum/comly" },
              "type" => "IssuesEvent"
            },
            %{ "actor" => %{ "login" => "rubum" },
               "payload" => %{
                    "action" => "created",
                    "comment" => %{
                      "author_association" => "OWNER",
                      "body" => "@rubum Have you checked this?",
                    }
                },
                "issue" => %{
                    "body" => "@rubum We need to test how to add a new user to a channel",
                },
                "public" => true,
                "repo" => %{ "name" => "rubum/comly" },
                "type" => "IssueCommentEvent"
            }
        ]     
    end
end