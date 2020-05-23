defmodule Web.Plugs.VerifyAdminTest do
  use Web.ConnCase

  alias Web.Plugs.VerifyAdmin

  describe "checks for an admin" do
    test "passes through if an admin", %{conn: conn} do
      user = TestHelpers.user_struct(%{role: "admin"})

      conn =
        conn
        |> assign(:current_user, user)
        |> bypass_through()
        |> get("/")
        |> VerifyAdmin.call([])

      refute conn.halted
    end

    test "halts as a 404 if not an admin", %{conn: conn} do
      user = TestHelpers.user_struct(%{role: "user"})

      conn =
        conn
        |> assign(:current_user, user)
        |> bypass_through(Web.Router, [:browser])
        |> get("/")
        |> VerifyAdmin.call([])

      assert conn.halted
    end

    test "halts as a 404 if no user", %{conn: conn} do
      conn =
        conn
        |> bypass_through(Web.Router, [:browser])
        |> get("/")
        |> VerifyAdmin.call([])

      assert conn.halted
    end
  end
end
