defmodule Web.MessageContextControllerTest do
  use Web.ConnCase

  alias ChallengeGov.Messages
  alias ChallengeGov.MessageContextStatuses
  alias ChallengeGov.TestHelpers.MessageContextStatusHelpers

  defp prep_conn(conn, user) do
    assign(conn, :current_user, user)
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

    @tag :skip
    # TODO: This needs to properly fetch all relevant drafts for a challenge owner
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
