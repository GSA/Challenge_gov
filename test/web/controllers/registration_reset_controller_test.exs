defmodule Web.RegistrationResetControllerTest do
  use Web.ConnCase

  alias ChallengeGov.Accounts

  describe "resets the token" do
    test "a real token", %{conn: conn} do
      user = TestHelpers.create_user()
      :ok = Accounts.start_password_reset(user.email)
      {:ok, user} = Accounts.get(user.id)

      params = %{
        token: user.password_reset_token,
        user: %{
          password: "password",
          password_confirmation: "password"
        }
      }

      conn = post(conn, Routes.registration_reset_path(conn, :update), params)

      assert redirected_to(conn) == Routes.session_path(conn, :new)

      {:ok, user} = Accounts.get(user.id)
      refute user.password_reset_token
    end

    test "an invalid token", %{conn: conn} do
      params = %{
        token: UUID.uuid4(),
        user: %{
          password: "password",
          password_confirmation: "password"
        }
      }

      conn = post(conn, Routes.registration_reset_path(conn, :update), params)

      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end
end
