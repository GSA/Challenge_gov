defmodule Web.AccountControllerTest do
  use Web.ConnCase

  describe "updating your information" do
    test "success", %{conn: conn} do
      user = TestHelpers.create_user(%{first_name: "John"})

      params = %{first_name: "Joe"}

      conn =
        conn
        |> assign(:current_user, user)
        |> put(Routes.account_path(conn, :update), user: params)

      assert redirected_to(conn) == Routes.account_path(conn, :edit)
    end

    test "failure", %{conn: conn} do
      user = TestHelpers.create_user(%{first_name: "John"})

      params = %{first_name: nil}

      conn =
        conn
        |> assign(:current_user, user)
        |> put(Routes.account_path(conn, :update), user: params)

      assert html_response(conn, 422)
    end
  end

  describe "updating your password" do
    test "success", %{conn: conn} do
      user = TestHelpers.create_user()

      params = %{password: "passw0rd", password_confirmation: "passw0rd"}

      conn =
        conn
        |> assign(:current_user, user)
        |> put(Routes.account_path(conn, :update), user: params)

      assert redirected_to(conn) == Routes.account_path(conn, :edit)

      flash = Phoenix.Controller.get_flash(conn)
      assert Map.has_key?(flash, "info")
    end

    test "failure", %{conn: conn} do
      user = TestHelpers.create_user()

      params = %{password: nil}

      conn =
        conn
        |> assign(:current_user, user)
        |> put(Routes.account_path(conn, :update), user: params)

      assert redirected_to(conn) == Routes.account_path(conn, :edit)

      flash = Phoenix.Controller.get_flash(conn)
      assert Map.has_key?(flash, "error")
    end
  end
end
