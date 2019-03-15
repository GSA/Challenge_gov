defmodule Web.ChallangeControllerTest do
  use Web.ConnCase

  describe "creating a new challenge" do
    test "success", %{conn: conn} do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)
      conn = assign(conn, :current_user, user)

      params = %{
        focus_area: "Transportation",
        name: "Bike lanes",
        description: "We need more bike lanes",
        why: "To bike around"
      }

      conn = post(conn, Routes.challenge_path(conn, :create), challenge: params)

      assert redirected_to(conn) == Routes.challenge_path(conn, :index)
    end

    test "failure submitting not verified", %{conn: conn} do
      user = TestHelpers.create_user()
      conn = assign(conn, :current_user, user)

      params = %{
        focus_area: "Transportation",
        name: "Bike lanes",
        description: "We need more bike lanes",
        why: "To bike around"
      }

      conn = post(conn, Routes.challenge_path(conn, :create), challenge: params)

      assert redirected_to(conn) == Routes.page_path(conn, :index)

      flash = Phoenix.Controller.get_flash(conn)
      assert Map.has_key?(flash, "error")
    end

    test "failure", %{conn: conn} do
      user = TestHelpers.create_user()
      user = TestHelpers.verify_email(user)
      conn = assign(conn, :current_user, user)

      params = %{
        name: "Bike lanes",
        description: "We need more bike lanes",
        why: "To bike around"
      }

      conn = post(conn, Routes.challenge_path(conn, :create), challenge: params)

      assert html_response(conn, 422)
    end
  end
end
