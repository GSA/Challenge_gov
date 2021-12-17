defmodule Web.MessageContextControllerTest do
  use Web.ConnCase

  alias ChallengeGov.Repo

  alias ChallengeGov.Challenges.ChallengeManager
  alias ChallengeGov.Messages
  alias ChallengeGov.MessageContexts
  alias ChallengeGov.MessageContextStatuses
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers
  alias ChallengeGov.TestHelpers.MessageContextStatusHelpers
  alias ChallengeGov.TestHelpers.SubmissionHelpers

  defp prep_conn(conn, user) do
    assign(conn, :current_user, user)
  end

  describe "sync message context statuses on index" do
    test "success: for admin", %{conn: conn} do
      MessageContextStatusHelpers.create_message_context_status()

      user_admin = AccountHelpers.create_user(%{role: "admin", email: "new_admin@example.com"})

      conn = prep_conn(conn, user_admin)

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :index
          )
        )

      %{message_context_statuses: message_context_statuses} = conn.assigns

      assert length(message_context_statuses) == 1

      assert html_response(conn, 200)
    end

    test "success: for challenge manager", %{conn: conn} do
      %{
        message_context: message_context,
        user_solver: user_solver
      } = MessageContextStatusHelpers.create_message_context_status()

      user_challenge_manager_new =
        AccountHelpers.create_user(%{
          role: "challenge_manager",
          email: "challenge_manager_new@example.com"
        })

      Messages.create(user_solver, message_context, %{
        "content" => "Test",
        "content_delta" => "Test",
        "status" => "sent"
      })

      challenge = MessageContexts.get_context_record(message_context)

      %ChallengeManager{}
      |> ChallengeManager.changeset(%{
        "challenge_id" => challenge.id,
        "user_id" => user_challenge_manager_new.id
      })
      |> Repo.insert()

      conn = prep_conn(conn, user_challenge_manager_new)

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :index
          )
        )

      %{message_context_statuses: message_context_statuses} = conn.assigns

      assert length(message_context_statuses) == 2

      assert html_response(conn, 200)
    end

    test "success: for solver", %{conn: conn} do
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

      user_solver_new =
        AccountHelpers.create_user(%{role: "solver", email: "solver_new@example.com"})

      _submission_new =
        SubmissionHelpers.create_submitted_submission(%{}, user_solver_new, challenge)

      conn = prep_conn(conn, user_solver_new)

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :index
          )
        )

      %{message_context_statuses: message_context_statuses} = conn.assigns

      assert length(message_context_statuses) == 1

      assert html_response(conn, 200)
    end
  end

  describe "filter starred" do
    test "success", %{conn: conn} do
      %{
        challenge_manager_message_context_status: challenge_manager_message_context_status,
        user_challenge_manager: user_challenge_manager
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_manager)

      {:ok, _message_context_status} =
        MessageContextStatuses.toggle_starred(challenge_manager_message_context_status)

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :index,
            filter: %{"starred" => true}
          )
        )

      %{message_context_statuses: message_context_statuses} = conn.assigns

      assert length(message_context_statuses) == 1

      assert html_response(conn, 200)
    end

    test "success: none", %{conn: conn} do
      %{
        user_challenge_manager: user_challenge_manager
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_manager)

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :index,
            filter: %{"starred" => true}
          )
        )

      %{message_context_statuses: message_context_statuses} = conn.assigns

      assert Enum.empty?(message_context_statuses)

      assert html_response(conn, 200)
    end
  end

  describe "filter archived" do
    test "success", %{conn: conn} do
      %{
        challenge_manager_message_context_status: challenge_manager_message_context_status,
        user_challenge_manager: user_challenge_manager
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_manager)

      {:ok, _message_context_status} =
        MessageContextStatuses.toggle_archived(challenge_manager_message_context_status)

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :index,
            filter: %{"archived" => true}
          )
        )

      %{message_context_statuses: message_context_statuses} = conn.assigns

      assert length(message_context_statuses) == 1

      assert html_response(conn, 200)
    end

    test "success: none", %{conn: conn} do
      %{
        user_challenge_manager: user_challenge_manager
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_manager)

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :index,
            filter: %{"archived" => true}
          )
        )

      %{message_context_statuses: message_context_statuses} = conn.assigns

      assert Enum.empty?(message_context_statuses)

      assert html_response(conn, 200)
    end
  end

  describe "filter read" do
    test "success", %{conn: conn} do
      %{
        challenge_manager_message_context_status: challenge_manager_message_context_status,
        user_challenge_manager: user_challenge_manager
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_manager)

      {:ok, _message_context_status} =
        MessageContextStatuses.toggle_read(challenge_manager_message_context_status)

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :index,
            filter: %{"read" => true}
          )
        )

      %{message_context_statuses: message_context_statuses} = conn.assigns

      assert length(message_context_statuses) == 1

      assert html_response(conn, 200)
    end

    test "success: none", %{conn: conn} do
      %{
        user_challenge_manager: user_challenge_manager
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_manager)

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :index,
            filter: %{"read" => true}
          )
        )

      %{message_context_statuses: message_context_statuses} = conn.assigns

      assert Enum.empty?(message_context_statuses)

      assert html_response(conn, 200)
    end
  end

  describe "filter by challenge" do
    test "success", %{conn: conn} do
      %{
        challenge: challenge,
        user_challenge_manager: user_challenge_manager
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_manager)

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :index,
            filter: %{"challenge_id" => challenge.id}
          )
        )

      %{message_context_statuses: message_context_statuses} = conn.assigns

      assert length(message_context_statuses) == 1

      assert html_response(conn, 200)
    end

    test "success: none", %{conn: conn} do
      %{
        challenge: challenge,
        user_challenge_manager: user_challenge_manager
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_manager)

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :index,
            filter: %{"challenge_id" => challenge.id + 1}
          )
        )

      %{message_context_statuses: message_context_statuses} = conn.assigns

      assert Enum.empty?(message_context_statuses)

      assert html_response(conn, 200)
    end
  end

  describe "new action for a challenge message context" do
    test "success: super admin", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "super_admin"})
      conn = prep_conn(conn, user)

      conn = get(conn, Routes.message_context_path(conn, :new), %{"context" => "challenge"})

      assert html_response(conn, 200)
    end

    test "success: admin", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "admin"})
      conn = prep_conn(conn, user)

      conn = get(conn, Routes.message_context_path(conn, :new), %{"context" => "challenge"})

      assert html_response(conn, 200)
    end

    test "success: challenge manager", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      conn = prep_conn(conn, user)

      conn = get(conn, Routes.message_context_path(conn, :new), %{"context" => "challenge"})

      assert html_response(conn, 200)
    end

    test "failure: solver", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "solver"})
      conn = prep_conn(conn, user)

      conn = get(conn, Routes.message_context_path(conn, :new), %{"context" => "challenge"})

      assert get_flash(conn, :error) == "You can not start a message thread"
      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.message_context_path(conn, :index)
    end
  end

  describe "creating a challenge message context" do
    test "success: super admin", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "super_admin"})
      conn = prep_conn(conn, user)

      challenge_manager =
        AccountHelpers.create_user(%{
          role: "challenge_manager",
          email: "challenge_manager@example.com"
        })

      challenge =
        ChallengeHelpers.create_challenge(%{user_id: challenge_manager.id}, challenge_manager)

      message_context_attributes = %{
        "context" => "challenge",
        "context_id" => challenge.id,
        "audience" => "all"
      }

      conn =
        post(conn, Routes.message_context_path(conn, :create), %{
          "message_context" => message_context_attributes
        })

      {:ok, context} = MessageContexts.get("challenge", challenge.id, "all")

      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.message_context_path(conn, :show, context.id)
    end

    test "success: admin", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "admin"})
      conn = prep_conn(conn, user)

      challenge_manager =
        AccountHelpers.create_user(%{
          role: "challenge_manager",
          email: "challenge_manager@example.com"
        })

      challenge =
        ChallengeHelpers.create_challenge(%{user_id: challenge_manager.id}, challenge_manager)

      message_context_attributes = %{
        "context" => "challenge",
        "context_id" => challenge.id,
        "audience" => "all"
      }

      conn =
        post(conn, Routes.message_context_path(conn, :create), %{
          "message_context" => message_context_attributes
        })

      {:ok, context} = MessageContexts.get("challenge", challenge.id, "all")

      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.message_context_path(conn, :show, context.id)
    end

    test "success: challenge manager", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      conn = prep_conn(conn, user)

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id}, user)

      message_context_attributes = %{
        "context" => "challenge",
        "context_id" => challenge.id,
        "audience" => "all"
      }

      conn =
        post(conn, Routes.message_context_path(conn, :create), %{
          "message_context" => message_context_attributes
        })

      {:ok, context} = MessageContexts.get("challenge", challenge.id, "all")

      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.message_context_path(conn, :show, context.id)
    end

    # TODO: Low priority check to add and test
    @tag :skip
    test "failure: challenge manager for unrelated challenge", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      conn = prep_conn(conn, user)

      challenge_manager =
        AccountHelpers.create_user(%{
          role: "challenge_manager",
          email: "challenge_manager@example.com"
        })

      challenge =
        ChallengeHelpers.create_challenge(%{user_id: challenge_manager.id}, challenge_manager)

      message_context_attributes = %{
        "context" => "challenge",
        "context_id" => challenge.id,
        "audience" => "all"
      }

      conn =
        post(conn, Routes.message_context_path(conn, :create), %{
          "message_context" => message_context_attributes
        })

      assert {:ok, _context} = MessageContexts.get("challenge", challenge.id, "all")

      assert get_flash(conn, :error) == "You can not start a message thread"
      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.message_context_path(conn, :index)
    end

    test "failure: solver", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "solver"})
      conn = prep_conn(conn, user)

      challenge_manager =
        AccountHelpers.create_user(%{
          role: "challenge_manager",
          email: "challenge_manager@example.com"
        })

      challenge =
        ChallengeHelpers.create_challenge(%{user_id: challenge_manager.id}, challenge_manager)

      message_context_attributes = %{
        "context" => "challenge",
        "context_id" => challenge.id,
        "audience" => "all"
      }

      conn =
        post(conn, Routes.message_context_path(conn, :create), %{
          "message_context" => message_context_attributes
        })

      assert {:error, :not_found} = MessageContexts.get("challenge", challenge.id, "all")

      assert get_flash(conn, :error) == "You can not start a message thread"
      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.message_context_path(conn, :index)
    end
  end

  describe "creating a challenge message context with challenge managers audience" do
    test "success: admin", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "admin"})
      conn = prep_conn(conn, user)

      challenge_manager =
        AccountHelpers.create_user(%{
          role: "challenge_manager",
          email: "challenge_manager@example.com"
        })

      challenge =
        ChallengeHelpers.create_challenge(%{user_id: challenge_manager.id}, challenge_manager)

      message_context_attributes = %{
        "context" => "challenge",
        "context_id" => challenge.id,
        "audience" => "challenge_managers"
      }

      conn =
        post(conn, Routes.message_context_path(conn, :create), %{
          "message_context" => message_context_attributes
        })

      {:ok, context} = MessageContexts.get("challenge", challenge.id, "challenge_managers")

      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.message_context_path(conn, :show, context.id)
    end

    test "success: challenge manager", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      conn = prep_conn(conn, user)

      challenge_manager =
        AccountHelpers.create_user(%{
          role: "challenge_manager",
          email: "challenge_manager@example.com"
        })

      challenge =
        ChallengeHelpers.create_challenge(%{user_id: challenge_manager.id}, challenge_manager)

      message_context_attributes = %{
        "context" => "challenge",
        "context_id" => challenge.id,
        "audience" => "challenge_managers"
      }

      conn =
        post(conn, Routes.message_context_path(conn, :create), %{
          "message_context" => message_context_attributes
        })

      {:ok, context} = MessageContexts.get("challenge", challenge.id, "challenge_managers")

      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.message_context_path(conn, :show, context.id)
    end

    test "failure: solver", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "solver"})
      conn = prep_conn(conn, user)

      challenge_manager =
        AccountHelpers.create_user(%{
          role: "challenge_manager",
          email: "challenge_manager@example.com"
        })

      challenge =
        ChallengeHelpers.create_challenge(%{user_id: challenge_manager.id}, challenge_manager)

      message_context_attributes = %{
        "context" => "challenge",
        "context_id" => challenge.id,
        "audience" => "challenge_managers"
      }

      conn =
        post(conn, Routes.message_context_path(conn, :create), %{
          "message_context" => message_context_attributes
        })

      assert {:error, :not_found} =
               MessageContexts.get("challenge", challenge.id, "challenge_managers")

      assert get_flash(conn, :error) == "You can not start a message thread"
      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.message_context_path(conn, :index)
    end
  end

  describe "render new message page for multi messaging" do
    test "success", %{conn: conn} do
      challenge_manager =
        AccountHelpers.create_user(%{role: "challenge_manager", email: "co@example.com"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(challenge_manager, %{
          user_id: challenge_manager.id
        })

      solver_1 = AccountHelpers.create_user(%{role: "solver", email: "s1@example.com"})
      submission_1 = SubmissionHelpers.create_submitted_submission(%{}, solver_1, challenge)

      solver_2 = AccountHelpers.create_user(%{role: "solver", email: "s2@example.com"})
      submission_2 = SubmissionHelpers.create_submitted_submission(%{}, solver_2, challenge)

      submission_ids = [submission_1.id, submission_2.id]

      conn = prep_conn(conn, challenge_manager)

      query_params = %{
        "cid" => challenge.id,
        "sid" => submission_ids
      }

      conn = post(conn, Routes.message_context_path(conn, :bulk_new), query_params)

      assert html_response(conn, 200)
    end
  end

  describe "multi messaging submission for a challenge" do
    test "success: with no existing parent challenge context", %{conn: conn} do
      challenge_manager =
        AccountHelpers.create_user(%{role: "challenge_manager", email: "co@example.com"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(challenge_manager, %{
          user_id: challenge_manager.id
        })

      solver_1 = AccountHelpers.create_user(%{role: "solver", email: "s1@example.com"})
      submission_1 = SubmissionHelpers.create_submitted_submission(%{}, solver_1, challenge)

      solver_2 = AccountHelpers.create_user(%{role: "solver", email: "s2@example.com"})
      submission_2 = SubmissionHelpers.create_submitted_submission(%{}, solver_2, challenge)

      submission_ids = [submission_1.id, submission_2.id]

      message_content = %{
        "content" => "Test",
        "content_delta" => "Test",
        "status" => "sent"
      }

      conn = prep_conn(conn, challenge_manager)

      conn =
        post(conn, Routes.message_context_path(conn, :bulk_message, challenge.id), %{
          "submission_ids" => submission_ids,
          "content" => message_content["content"],
          "content_delta" => message_content["content_delta"]
        })

      {:ok, challenge_message_context} = MessageContexts.get("challenge", challenge.id, "all")
      challenge_message_context = Repo.preload(challenge_message_context, [:messages])
      assert Enum.empty?(challenge_message_context.messages)

      {:ok, solver_message_context_1} =
        MessageContexts.get("solver", solver_1.id, "all", challenge_message_context.id)

      solver_message_context_1 = Repo.preload(solver_message_context_1, [:messages])
      assert length(solver_message_context_1.messages) == 1
      assert Enum.at(solver_message_context_1.messages, 0).content == "Test"

      {:ok, solver_message_context_2} =
        MessageContexts.get("solver", solver_2.id, "all", challenge_message_context.id)

      solver_message_context_2 = Repo.preload(solver_message_context_2, [:messages])
      assert length(solver_message_context_2.messages) == 1
      assert Enum.at(solver_message_context_2.messages, 0).content == "Test"

      assert get_flash(conn, :info) == "Message sent to selected submissions"
      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.message_context_path(conn, :index)
    end

    test "success: with existing parent challenge context", %{conn: conn} do
      challenge_manager =
        AccountHelpers.create_user(%{role: "challenge_manager", email: "co@example.com"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(challenge_manager, %{
          user_id: challenge_manager.id
        })

      solver_1 = AccountHelpers.create_user(%{role: "solver", email: "s1@example.com"})
      submission_1 = SubmissionHelpers.create_submitted_submission(%{}, solver_1, challenge)

      solver_2 = AccountHelpers.create_user(%{role: "solver", email: "s2@example.com"})
      submission_2 = SubmissionHelpers.create_submitted_submission(%{}, solver_2, challenge)

      {:ok, challenge_message_context} =
        MessageContexts.create(%{
          "context" => "challenge",
          "context_id" => challenge.id,
          "audience" => "all"
        })

      {:ok, _solver_message_context_1} =
        MessageContexts.create(%{
          "context" => "solver",
          "context_id" => submission_1.submitter_id,
          "audience" => "all",
          "parent_id" => challenge_message_context.id
        })

      submission_ids = [submission_1.id, submission_2.id]

      message_content = %{
        "content" => "Test",
        "content_delta" => "Test",
        "status" => "sent"
      }

      conn = prep_conn(conn, challenge_manager)

      conn =
        post(conn, Routes.message_context_path(conn, :bulk_message, challenge.id), %{
          "submission_ids" => submission_ids,
          "content" => message_content["content"],
          "content_delta" => message_content["content_delta"]
        })

      {:ok, challenge_message_context} = MessageContexts.get("challenge", challenge.id, "all")
      challenge_message_context = Repo.preload(challenge_message_context, [:messages])
      assert Enum.empty?(challenge_message_context.messages)

      {:ok, solver_message_context_1} =
        MessageContexts.get("solver", solver_1.id, "all", challenge_message_context.id)

      solver_message_context_1 = Repo.preload(solver_message_context_1, [:messages])
      assert length(solver_message_context_1.messages) == 1
      assert Enum.at(solver_message_context_1.messages, 0).content == "Test"

      {:ok, solver_message_context_2} =
        MessageContexts.get("solver", solver_2.id, "all", challenge_message_context.id)

      solver_message_context_2 = Repo.preload(solver_message_context_2, [:messages])
      assert length(solver_message_context_2.messages) == 1
      assert Enum.at(solver_message_context_2.messages, 0).content == "Test"

      assert get_flash(conn, :info) == "Message sent to selected submissions"
      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.message_context_path(conn, :index)
    end

    # TODO: Make a test and checks for permissions for challenge/solvers, missing message content, etc
    @tag :skip
    test "failure: current user not allowed to make context for challenge"

    @tag :skip
    test "failure: empty message contents"

    @tag :skip
    test "failure: no solvers selected"
  end

  describe "viewing message context" do
    test "success: super admin", %{conn: conn} do
      %{
        user_super_admin: user,
        message_context: context
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user)

      conn = get(conn, Routes.message_context_path(conn, :show, context.id))

      assert html_response(conn, 200)
    end

    test "success: admin", %{conn: conn} do
      %{
        user_admin: user,
        message_context: context
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user)

      conn = get(conn, Routes.message_context_path(conn, :show, context.id))

      assert html_response(conn, 200)
    end

    test "success: challenge manager", %{conn: conn} do
      %{
        user_challenge_manager: user,
        message_context: context
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user)

      conn = get(conn, Routes.message_context_path(conn, :show, context.id))

      assert html_response(conn, 200)
    end

    test "failure: challenge manager unrelated to context", %{conn: conn} do
      %{
        message_context: context
      } = MessageContextStatusHelpers.create_message_context_status()

      user =
        AccountHelpers.create_user(%{role: "challenge_manager", email: "new_user@example.com"})

      conn = prep_conn(conn, user)

      conn = get(conn, Routes.message_context_path(conn, :show, context.id))

      assert get_flash(conn, :error) == "You can not view that thread"
      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.message_context_path(conn, :index)
    end

    test "success: solver", %{conn: conn} do
      %{
        user_solver: user,
        message_context: context
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user)

      conn = get(conn, Routes.message_context_path(conn, :show, context.id))

      assert html_response(conn, 200)
    end

    test "failure: solver unrelated to context", %{conn: conn} do
      %{
        message_context: context
      } = MessageContextStatusHelpers.create_message_context_status()

      user = AccountHelpers.create_user(%{role: "solver", email: "new_user@example.com"})

      conn = prep_conn(conn, user)

      conn = get(conn, Routes.message_context_path(conn, :show, context.id))

      assert get_flash(conn, :error) == "You can not view that thread"
      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.message_context_path(conn, :index)
    end
  end

  describe "viewing drafts" do
    test "success", %{conn: conn} do
      %{
        message_context: message_context,
        user_challenge_manager: user_challenge_manager
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_manager)

      {:ok, _message} =
        Messages.create(user_challenge_manager, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :drafts
          )
        )

      %{draft_messages: draft_messages} = conn.assigns

      assert length(draft_messages) == 1
      assert html_response(conn, 200)
    end

    test "success: as second challenge manager", %{conn: conn} do
      %{
        message_context: message_context,
        user_challenge_manager: user_challenge_manager,
        user_challenge_manager_2: user_challenge_manager_2
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_manager_2)

      {:ok, _message} =
        Messages.create(user_challenge_manager, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :drafts
          )
        )

      %{draft_messages: draft_messages} = conn.assigns

      assert length(draft_messages) == 1
      assert html_response(conn, 200)
    end

    test "success: as admin don't see challenge manager drafts", %{conn: conn} do
      %{
        message_context: message_context,
        user_challenge_manager: user_challenge_manager
      } = MessageContextStatusHelpers.create_message_context_status()

      user_super_admin =
        AccountHelpers.create_user(%{
          email: "new_super_admin@example.com",
          role: "super_admin"
        })

      conn = prep_conn(conn, user_super_admin)

      {:ok, _message} =
        Messages.create(user_challenge_manager, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :drafts
          )
        )

      %{draft_messages: draft_messages} = conn.assigns

      assert Enum.empty?(draft_messages)
      assert html_response(conn, 200)
    end

    test "success: as solver no drafts", %{conn: conn} do
      %{
        user_solver: user_solver
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_solver)

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :drafts
          )
        )

      %{draft_messages: draft_messages} = conn.assigns

      assert Enum.empty?(draft_messages)
      assert html_response(conn, 200)
    end
  end

  describe "viewing message context with a draft message" do
    test "success", %{conn: conn} do
      %{
        message_context: message_context,
        user_challenge_manager: user_challenge_manager
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_manager)

      {:ok, message} =
        Messages.create(user_challenge_manager, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :show,
            message_context.id,
            message_id: message.id
          )
        )

      %{changeset: changeset} = conn.assigns

      assert changeset.data.id == message.id
      assert html_response(conn, 200)
    end

    test "success: challenge manager viewing another challenge manager draft", %{conn: conn} do
      %{
        message_context: message_context,
        user_challenge_manager: user_challenge_manager,
        user_challenge_manager_2: user_challenge_manager_2
      } = MessageContextStatusHelpers.create_message_context_status()

      {:ok, message} =
        Messages.create(user_challenge_manager, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      conn = prep_conn(conn, user_challenge_manager_2)

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :show,
            message_context.id,
            message_id: message.id
          )
        )

      %{changeset: changeset} = conn.assigns

      assert changeset.data.id == message.id
      assert html_response(conn, 200)
    end

    test "success: challenge manager viewing another challenge manager draft on solver context",
         %{
           conn: conn
         } do
      %{
        message_context: message_context,
        user_challenge_manager: user_challenge_manager,
        user_challenge_manager_2: user_challenge_manager_2,
        user_solver: user_solver
      } = MessageContextStatusHelpers.create_message_context_status()

      {:ok, solver_message_context} =
        MessageContexts.create(%{
          "context" => "solver",
          "context_id" => user_solver.id,
          "audience" => "all",
          "parent_id" => message_context.id
        })

      {:ok, message} =
        Messages.create(user_challenge_manager, solver_message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      conn = prep_conn(conn, user_challenge_manager_2)

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :show,
            solver_message_context.id,
            message_id: message.id
          )
        )

      %{changeset: changeset} = conn.assigns

      assert changeset.data.id == message.id
      assert html_response(conn, 200)
    end

    test "failure: invalid author", %{conn: conn} do
      %{
        user_super_admin: user_super_admin,
        user_challenge_manager: user_challenge_manager,
        message_context: message_context
      } = MessageContextStatusHelpers.create_message_context_status()

      {:ok, message} =
        Messages.create(user_challenge_manager, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      conn = prep_conn(conn, user_super_admin)

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :show,
            message_context.id,
            message_id: message.id
          )
        )

      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.message_context_path(conn, :show, message_context.id)
    end

    test "failure: invalid author challenge manager", %{conn: conn} do
      %{
        user_challenge_manager: user_challenge_manager,
        message_context: message_context
      } = MessageContextStatusHelpers.create_message_context_status()

      {:ok, message} =
        Messages.create(user_challenge_manager, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      new_user =
        AccountHelpers.create_user(%{role: "challenge_manager", email: "new_user@example.com"})

      conn = prep_conn(conn, new_user)

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :show,
            message_context.id,
            message_id: message.id
          )
        )

      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.message_context_path(conn, :show, message_context.id)
    end

    test "failure: invalid author challenge manager on solver context", %{conn: conn} do
      %{
        message_context: message_context,
        user_challenge_manager: user_challenge_manager,
        user_solver: user_solver
      } = MessageContextStatusHelpers.create_message_context_status()

      {:ok, solver_message_context} =
        MessageContexts.create(%{
          "context" => "solver",
          "context_id" => user_solver.id,
          "audience" => "all",
          "parent_id" => message_context.id
        })

      {:ok, message} =
        Messages.create(user_challenge_manager, solver_message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      new_user =
        AccountHelpers.create_user(%{role: "challenge_manager", email: "new_user@example.com"})

      conn = prep_conn(conn, new_user)

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :show,
            solver_message_context.id,
            message_id: message.id
          )
        )

      assert html_response(conn, 302)
      redir_path = Routes.message_context_path(conn, :show, solver_message_context.id)
      assert redirected_to(conn) == redir_path

      conn = prep_conn(recycle(conn), new_user)
      conn = get(conn, redir_path)

      assert get_flash(conn, :error) == "You can not view that thread"
      assert html_response(conn, 302)
      redir_path = Routes.message_context_path(conn, :index)
      assert redirected_to(conn) == redir_path
    end

    test "failure: message not part of context", %{conn: conn} do
      %{
        user_challenge_manager: user_challenge_manager,
        message_context: message_context
      } = MessageContextStatusHelpers.create_message_context_status()

      {:ok, message} =
        Messages.create(user_challenge_manager, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      new_user =
        AccountHelpers.create_user(%{role: "challenge_manager", email: "new_user@example.com"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(new_user, %{
          user_id: new_user.id
        })

      {:ok, new_message_context} =
        MessageContexts.create(%{
          "context" => "challenge",
          "context_id" => challenge.id,
          "audience" => "all"
        })

      conn = prep_conn(conn, new_user)

      conn =
        get(
          conn,
          Routes.message_context_path(
            conn,
            :show,
            new_message_context.id,
            message_id: message.id
          )
        )

      assert html_response(conn, 302)

      assert redirected_to(conn) ==
               Routes.message_context_path(conn, :show, new_message_context.id)
    end
  end
end
