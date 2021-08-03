defmodule Web.MessageContextControllerTest do
  use Web.ConnCase

  alias ChallengeGov.Repo

  alias ChallengeGov.Challenges.ChallengeOwner
  alias ChallengeGov.Messages
  alias ChallengeGov.MessageContexts
  alias ChallengeGov.MessageContextStatuses
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.MessageContextStatusHelpers
  alias ChallengeGov.TestHelpers.SubmissionHelpers

  defp prep_conn(conn, user) do
    assign(conn, :current_user, user)
  end

  describe "sync message context statuses on index" do
    test "success: for admin", %{conn: conn} do
      MessageContextStatusHelpers.create_message_context_status()

      user_admin = AccountHelpers.create_user(%{role: "admin", email: "admin@example.com"})

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

    test "success: for challenge owner", %{conn: conn} do
      %{
        message_context: message_context,
        user_solver: user_solver
      } = MessageContextStatusHelpers.create_message_context_status()

      user_challenge_owner_new =
        AccountHelpers.create_user(%{
          role: "challenge_owner",
          email: "challenge_owner_new@example.com"
        })

      Messages.create(user_solver, message_context, %{
        "content" => "Test",
        "content_delta" => "Test",
        "status" => "sent"
      })

      challenge = MessageContexts.get_context_record(message_context)

      %ChallengeOwner{}
      |> ChallengeOwner.changeset(%{
        "challenge_id" => challenge.id,
        "user_id" => user_challenge_owner_new.id
      })
      |> Repo.insert()

      conn = prep_conn(conn, user_challenge_owner_new)

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
        challenge_owner_message_context_status: challenge_owner_message_context_status,
        user_challenge_owner: user_challenge_owner
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_owner)

      {:ok, _message_context_status} =
        MessageContextStatuses.toggle_starred(challenge_owner_message_context_status)

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
        user_challenge_owner: user_challenge_owner
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_owner)

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
        challenge_owner_message_context_status: challenge_owner_message_context_status,
        user_challenge_owner: user_challenge_owner
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_owner)

      {:ok, _message_context_status} =
        MessageContextStatuses.toggle_archived(challenge_owner_message_context_status)

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
        user_challenge_owner: user_challenge_owner
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_owner)

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
        challenge_owner_message_context_status: challenge_owner_message_context_status,
        user_challenge_owner: user_challenge_owner
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_owner)

      {:ok, _message_context_status} =
        MessageContextStatuses.toggle_read(challenge_owner_message_context_status)

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
        user_challenge_owner: user_challenge_owner
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_owner)

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
        user_challenge_owner: user_challenge_owner
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_owner)

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
        user_challenge_owner: user_challenge_owner
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_owner)

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

  describe "viewing drafts" do
    test "success", %{conn: conn} do
      %{
        message_context: message_context,
        user_challenge_owner: user_challenge_owner
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_owner)

      {:ok, _message} =
        Messages.create(user_challenge_owner, message_context, %{
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

    test "success: as second challenge owner", %{conn: conn} do
      %{
        message_context: message_context,
        user_challenge_owner: user_challenge_owner,
        user_challenge_owner_2: user_challenge_owner_2
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_owner_2)

      {:ok, _message} =
        Messages.create(user_challenge_owner, message_context, %{
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

    test "success: as admin don't see challenge owner drafts", %{conn: conn} do
      %{
        message_context: message_context,
        user_challenge_owner: user_challenge_owner
      } = MessageContextStatusHelpers.create_message_context_status()

      user_super_admin =
        AccountHelpers.create_user(%{
          email: "super_admin@example.com",
          role: "super_admin"
        })

      conn = prep_conn(conn, user_super_admin)

      {:ok, _message} =
        Messages.create(user_challenge_owner, message_context, %{
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
        user_challenge_owner: user_challenge_owner
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_owner)

      {:ok, message} =
        Messages.create(user_challenge_owner, message_context, %{
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
  end
end
