defmodule Web.Admin.TeamControllerTest do
  use Web.ConnCase

  describe "updating a team" do
    test "success", %{conn: conn} do
      user = TestHelpers.create_user()
      team = TestHelpers.create_team(user)

      params = %{name: "Updated"}

      conn =
        conn
        |> assign(:current_user, %{user | role: "admin"})
        |> put(Routes.admin_team_path(conn, :update, team.id), team: params)

      assert redirected_to(conn) == Routes.admin_team_path(conn, :show, team.id)
    end

    test "failure", %{conn: conn} do
      user = TestHelpers.create_user()
      team = TestHelpers.create_team(user)

      params = %{name: nil}

      conn =
        conn
        |> assign(:current_user, %{user | role: "admin"})
        |> put(Routes.admin_team_path(conn, :update, team.id), team: params)

      assert html_response(conn, 422)
    end
  end
end
