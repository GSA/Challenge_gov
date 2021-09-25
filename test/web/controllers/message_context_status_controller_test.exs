defmodule Web.MessageContextStatusControllerTest do
  use Web.ConnCase

  alias ChallengeGov.TestHelpers.MessageContextStatusHelpers

  defp prep_conn(conn, user) do
    assign(conn, :current_user, user)
  end

  describe "mark read" do
    test "success", %{conn: conn} do
      %{
        challenge_manager_message_context_status: challenge_manager_message_context_status,
        user_challenge_manager: user_challenge_manager
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_manager)

      conn =
        post(
          conn,
          Routes.message_context_status_path(
            conn,
            :mark_read,
            challenge_manager_message_context_status.id
          )
        )

      assert get_flash(conn, :info) == "Message thread marked as read"
      assert html_response(conn, 302)
    end
  end

  describe "mark unread" do
    test "success", %{conn: conn} do
      %{
        challenge_manager_message_context_status: challenge_manager_message_context_status,
        user_challenge_manager: user_challenge_manager
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_manager)

      conn =
        post(
          conn,
          Routes.message_context_status_path(
            conn,
            :mark_unread,
            challenge_manager_message_context_status.id
          )
        )

      assert get_flash(conn, :info) == "Message thread marked as unread"
      assert html_response(conn, 302)
    end
  end

  describe "archive" do
    test "success", %{conn: conn} do
      %{
        challenge_manager_message_context_status: challenge_manager_message_context_status,
        user_challenge_manager: user_challenge_manager
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_manager)

      conn =
        post(
          conn,
          Routes.message_context_status_path(
            conn,
            :archive,
            challenge_manager_message_context_status.id
          )
        )

      assert get_flash(conn, :info) == "Message thread archived"
      assert html_response(conn, 302)
    end
  end

  describe "unarchive" do
    test "success", %{conn: conn} do
      %{
        challenge_manager_message_context_status: challenge_manager_message_context_status,
        user_challenge_manager: user_challenge_manager
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_manager)

      conn =
        post(
          conn,
          Routes.message_context_status_path(
            conn,
            :unarchive,
            challenge_manager_message_context_status.id
          )
        )

      assert get_flash(conn, :info) == "Message thread unarchived"
      assert html_response(conn, 302)
    end
  end
end
