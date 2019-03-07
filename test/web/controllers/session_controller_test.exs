defmodule Web.SessionControllerTest do
  use Web.ConnCase

  describe "signing in" do
    test "successful", %{conn: conn} do
      user = TestHelpers.create_user(%{email: "user@example.com", password: "password"})

      params = %{email: user.email, password: "password"}

      conn = post(conn, Routes.session_path(conn, :create), user: params)

      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end

    test "invalid", %{conn: conn} do
      user = TestHelpers.create_user(%{email: "user@example.com", password: "password"})

      params = %{email: user.email, password: "passw0rd"}

      conn = post(conn, Routes.session_path(conn, :create), user: params)

      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  describe "signing out" do
    test "successful", %{conn: conn} do
      user = TestHelpers.create_user(%{email: "user@example.com", password: "password"})

      conn = assign(conn, :current_user, user)

      conn = delete(conn, Routes.session_path(conn, :delete))

      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end
  end
end
