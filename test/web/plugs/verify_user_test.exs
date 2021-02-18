defmodule Web.Plugs.VerifyUserTest do
  use Web.ConnCase

  alias Web.Plugs.VerifyUser

  describe "checks for a user" do
    test "passes through if a user", %{conn: conn} do
      user = TestHelpers.user_struct()

      conn =
        conn
        |> assign(:current_user, user)
        |> bypass_through()
        |> get("/challenges/new")
        |> Plug.Conn.fetch_session()
        |> VerifyUser.call([])

      refute conn.halted
    end

    test "redirects to the session page", %{conn: conn} do
      conn =
        conn
        |> bypass_through(Web.Router, [:browser])
        |> get("/challenges/new")
        |> Plug.Conn.fetch_session()
        |> VerifyUser.call([])

      assert conn.halted
    end
  end
end
