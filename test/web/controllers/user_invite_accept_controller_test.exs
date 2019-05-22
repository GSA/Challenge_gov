defmodule Web.UserInviteAcceptControllerTest do
  use Web.ConnCase

  describe "accepting your invite" do
    test "successfully", %{conn: conn} do
      user = TestHelpers.create_invited_user()

      params = %{
        first_name: "User",
        last_name: "Example",
        phone_number: "123-123-1234",
        password: "password",
        password_confirmation: "password"
      }

      conn =
        post(conn, Routes.user_invite_accept_path(conn, :create),
          token: user.email_verification_token,
          user: params
        )

      assert redirected_to(conn) == Routes.challenge_path(conn, :index)
    end

    test "failure", %{conn: conn} do
      user = TestHelpers.create_invited_user()

      conn =
        post(conn, Routes.user_invite_accept_path(conn, :create),
          token: user.email_verification_token,
          user: %{}
        )

      assert html_response(conn, 422)
    end

    test "token not found", %{conn: conn} do
      conn =
        post(conn, Routes.user_invite_accept_path(conn, :create), token: UUID.uuid4(), user: %{})

      assert html_response(conn, 422)
    end
  end
end
