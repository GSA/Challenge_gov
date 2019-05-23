defmodule Web.UserInviteControllerTest do
  use Web.ConnCase

  describe "inviting a new user" do
    test "successfully", %{conn: conn} do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)

      params = %{
        email: "invitee@example.com"
      }

      conn =
        conn
        |> assign(:current_user, user)
        |> post(Routes.user_invite_path(conn, :create), user: params)

      assert redirected_to(conn) == Routes.challenge_path(conn, :index)
    end

    test "failure", %{conn: conn} do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)

      params = %{}

      conn =
        conn
        |> assign(:current_user, user)
        |> post(Routes.user_invite_path(conn, :create), user: params)

      assert redirected_to(conn) == Routes.user_invite_path(conn, :new)
    end
  end
end
