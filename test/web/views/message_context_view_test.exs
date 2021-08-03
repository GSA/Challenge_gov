defmodule Web.MessageContextViewTest do
  use Web.ConnCase, async: true

  alias ChallengeGov.Messages
  alias ChallengeGov.MessageContexts

  alias Web.MessageContextView

  alias ChallengeGov.TestHelpers.MessageContextStatusHelpers

  describe "display challenge title link" do
    test "success: challenge context" do
      %{
        challenge: challenge,
        message_context: message_context
      } = MessageContextStatusHelpers.create_message_context_status()

      assert MessageContextView.display_challenge_title_link(message_context) ==
               {:safe,
                [
                  60,
                  "a",
                  [[32, "href", 61, 34, "/challenges/#{challenge.id}", 34]],
                  62,
                  "Test challenge",
                  60,
                  47,
                  "a",
                  62
                ]}
    end

    test "success: solver context" do
      %{
        challenge: challenge,
        message_context: message_context,
        user_solver: user_solver
      } = MessageContextStatusHelpers.create_message_context_status()

      Messages.create(user_solver, message_context, %{
        "content" => "Test",
        "content_delta" => "Test",
        "status" => "sent"
      })

      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      assert MessageContextView.display_challenge_title_link(message_context_solver) ==
               {:safe,
                [
                  60,
                  "a",
                  [[32, "href", 61, 34, "/challenges/#{challenge.id}", 34]],
                  62,
                  "Test challenge",
                  60,
                  47,
                  "a",
                  62
                ]}
    end
  end

  describe "get active message filter class" do
    test "success: all" do
      conn = %{params: %{}}

      assert MessageContextView.filter_active_class(conn, "all") == "btn-primary"
      assert MessageContextView.filter_active_class(conn, "non_active_filter") == "btn-link"
    end

    test "success: starred" do
      conn = %{
        params: %{
          "filter" => %{
            "starred" => "true"
          }
        }
      }

      assert MessageContextView.filter_active_class(conn, "starred") == "btn-primary"
      assert MessageContextView.filter_active_class(conn, "non_active_filter") == "btn-link"
    end
  end
end
