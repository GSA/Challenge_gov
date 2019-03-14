defmodule Web.Plugs.VerifyNoUserTest do
  use Web.ConnCase

  alias Web.Plugs.VerifyNoUser

  describe "checks for no user loaded" do
    test "passes through if no user", %{conn: conn} do
      conn =
        conn
        |> bypass_through()
        |> get("/challenges/new")
        |> VerifyNoUser.call([])

      refute conn.halted
    end

    test "redirects to the home page", %{conn: conn} do
      user = TestHelpers.user_struct()

      conn =
        conn
        |> assign(:current_user, user)
        |> bypass_through(Web.Router, [:browser])
        |> get("/challenges/new")
        |> VerifyNoUser.call([])

      assert conn.halted
    end
  end
end
