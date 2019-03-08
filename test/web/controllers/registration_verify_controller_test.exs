defmodule Web.RegistrationVerifyControllerTest do
  use Web.ConnCase

  alias IdeaPortal.Accounts

  describe "verifies the token" do
    test "a real token", %{conn: conn} do
      user = TestHelpers.create_user()

      conn = get(conn, Routes.registration_verify_path(conn, :show, token: user.email_verification_token))

      assert redirected_to(conn) == Routes.page_path(conn, :index)

      {:ok, user} = Accounts.get_by_token(user.token)
      refute user.email_verification_token
    end

    test "an invalid token", %{conn: conn} do
      conn = get(conn, Routes.registration_verify_path(conn, :show, token: UUID.uuid4()))

      assert redirected_to(conn) == Routes.page_path(conn, :index)

      flash = Phoenix.Controller.get_flash(conn)
      assert Map.has_key?(flash, "error")
    end
  end
end
