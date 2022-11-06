defmodule Web.MessageContextViewTest do
  use Web.ConnCase, async: true

  alias ChallengeGov.Messages
  alias ChallengeGov.MessageContexts

  alias Web.AccountView
  alias Web.MessageContextView

  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers
  alias ChallengeGov.TestHelpers.SubmissionHelpers
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

  describe "display audience" do
    test "success: challenge context" do
      %{
        message_context: message_context,
        user_challenge_manager: user_challenge_manager
      } = MessageContextStatusHelpers.create_message_context_status()

      assert MessageContextView.display_audience(user_challenge_manager, message_context) == "All"
    end

    test "success: solver context as non solver" do
      %{
        message_context: message_context,
        user_challenge_manager: user_challenge_manager,
        user_solver: user_solver
      } = MessageContextStatusHelpers.create_message_context_status()

      Messages.create(user_solver, message_context, %{
        "content" => "Test",
        "content_delta" => "Test",
        "status" => "sent"
      })

      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      assert MessageContextView.display_audience(user_challenge_manager, message_context_solver) ==
               AccountView.full_name(user_solver)
    end

    test "success: solver context as solver" do
      %{
        message_context: message_context,
        user_solver: user_solver
      } = MessageContextStatusHelpers.create_message_context_status()

      Messages.create(user_solver, message_context, %{
        "content" => "Test",
        "content_delta" => "Test",
        "status" => "sent"
      })

      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      assert MessageContextView.display_audience(user_solver, message_context_solver) == "All"
    end
  end

  describe "display multi submission titles" do
    test "success" do
      challenge_manager =
        AccountHelpers.create_user(%{role: "challenge_manager", email: "co@example.com"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(challenge_manager, %{
          user_id: challenge_manager.id
        })

      solver_1 = AccountHelpers.create_user(%{role: "solver", email: "s1@example.com"})

      submission_1 =
        SubmissionHelpers.create_submitted_submission(
          %{"title" => "Submission 1"},
          solver_1,
          challenge
        )

      solver_2 = AccountHelpers.create_user(%{role: "solver", email: "s2@example.com"})

      submission_2 =
        SubmissionHelpers.create_submitted_submission(
          %{"title" => "Submission 2"},
          solver_2,
          challenge
        )

      submission_ids = [submission_1.id, submission_2.id]

      assert MessageContextView.display_multi_submission_titles(submission_ids) ==
               "Submission 1, Submission 2"
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

  describe "rendering audience column" do
    test "success: header" do
      %{
        user_challenge_manager: user
      } = MessageContextStatusHelpers.create_message_context_status()

      assert MessageContextView.maybe_render_audience_header(user) ==
               {:safe, [60, "th", [], 62, "Audience", 60, 47, "th", 62]}
    end

    test "failure: do not render header for solver" do
      %{
        user_solver: user
      } = MessageContextStatusHelpers.create_message_context_status()

      refute MessageContextView.maybe_render_audience_header(user)
    end

    test "success: column" do
      %{
        message_context: context,
        user_challenge_manager: user
      } = MessageContextStatusHelpers.create_message_context_status()

      assert MessageContextView.maybe_render_audience_column(user, context) ==
               {:safe, [60, "td", [], 62, "All", 60, 47, "td", 62]}
    end

    test "failure: do not render column for solver" do
      %{
        message_context: context,
        user_solver: user
      } = MessageContextStatusHelpers.create_message_context_status()

      refute MessageContextView.maybe_render_audience_column(user, context)
    end
  end

  describe "rendering new message button" do
    test "success", %{conn: conn} do
      %{
        user_challenge_manager: user
      } = MessageContextStatusHelpers.create_message_context_status()

      assert MessageContextView.render_new_message_button(conn, user) ==
               {:safe,
                [
                  60,
                  "a",
                  [
                    [32, "class", 61, 34, "btn btn-primary me-3", 34],
                    [32, "href", 61, 34, "/messages/new?context=challenge", 34]
                  ],
                  62,
                  "New Message",
                  60,
                  47,
                  "a",
                  62
                ]}
    end

    test "failure: do not render for solver", %{conn: conn} do
      %{
        user_solver: user
      } = MessageContextStatusHelpers.create_message_context_status()

      refute MessageContextView.render_new_message_button(conn, user)
    end
  end
end
