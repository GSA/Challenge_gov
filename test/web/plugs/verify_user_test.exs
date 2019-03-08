defmodule Web.Plugs.VerifyUserTest do
  use Web.ConnCase

  alias Web.Plugs.VerifyUser

  describe "checks for an admin" do
    test "passes through if an admin", %{conn: conn} do
      user = TestHelpers.user_struct()

      conn =
        conn
        |> assign(:current_user, user)
        |> bypass_through()
        |> get("/challenges/new")
        |> VerifyUser.call([])

      refute conn.halted
    end

    test "redirects to the session page", %{conn: conn} do
      conn =
        conn
        |> bypass_through()
        |> get("/challenges/new")
        |> VerifyUser.call([])

      assert conn.halted
    end
  end
end
