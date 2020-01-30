defmodule Web.Admin.AgencyControllerTest do
  use Web.ConnCase

  describe "updating a team" do
    test "success", %{conn: conn} do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)
      team = TestHelpers.create_team(user)

      params = %{name: "Updated"}

      conn =
        conn
        |> assign(:current_user, %{user | role: "admin"})
        |> put(Routes.admin_agency_path(conn, :update, team.id), team: params)

      assert redirected_to(conn) == Routes.admin_agency_path(conn, :show, team.id)
    end

    test "failure", %{conn: conn} do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)
      team = TestHelpers.create_team(user)

      params = %{name: nil}

      conn =
        conn
        |> assign(:current_user, %{user | role: "admin"})
        |> put(Routes.admin_agency_path(conn, :update, team.id), team: params)

      assert html_response(conn, 422)
    end
  end

  describe "deleting a team" do
    test "success", %{conn: conn} do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)
      team = TestHelpers.create_team(user)

      conn =
        conn
        |> assign(:current_user, %{user | role: "admin"})
        |> delete(Routes.admin_agency_path(conn, :delete, team.id))

      assert redirected_to(conn) == Routes.admin_agency_path(conn, :index)
    end
  end
end
