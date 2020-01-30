defmodule Web.AgencyControllerTest do
  use Web.ConnCase

  describe "creating a new team" do
    test "success", %{conn: conn} do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)

      conn =
        conn
        |> assign(:current_user, user)
        |> post(Routes.team_path(conn, :create), team: %{name: "Team"})

      assert redirected_to(conn)
    end

    test "failure", %{conn: conn} do
      user = TestHelpers.create_user()

      conn =
        conn
        |> assign(:current_user, user)
        |> post(Routes.team_path(conn, :create), team: %{})

      assert html_response(conn, 422)
    end
  end
end
