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

  describe "viewing accounts" do
    test "viewing all accounts", %{conn: conn} do
      user = TestHelpers.create_user(%{email: "current_user@example.com"})
      TestHelpers.create_user(%{email: "viewed_user@example.com"})

      conn =
        conn
        |> assign(:current_user, user)
        |> get(Routes.account_path(conn, :index))

      assert html_response(conn, 200)
    end

    test "searching accounts by email", %{conn: conn} do
      user = TestHelpers.create_user(%{email: "current_user@example.com"})
      TestHelpers.create_user(%{email: "viewed_user@example.com"})

      conn =
        conn
        |> assign(:current_user, user)
        |> get(Routes.account_path(conn, :index, filter: %{search: "viewed_user@example.com"}))

      assert html_response(conn, 200)
    end

    test "searching accounts by first name", %{conn: conn} do
      user = TestHelpers.create_user(%{email: "current_user@example.com"})

      TestHelpers.create_user(%{
        first_name: "viewed_user_first_name",
        email: "viewed_user@example.com"
      })

      conn =
        conn
        |> assign(:current_user, user)
        |> get(Routes.account_path(conn, :index, filter: %{search: "viewed_user_first_name"}))

      assert html_response(conn, 200)
    end

    test "searching accounts by last name", %{conn: conn} do
      user = TestHelpers.create_user(%{email: "current_user@example.com"})

      TestHelpers.create_user(%{
        last_name: "viewed_user_last_name",
        email: "viewed_user@example.com"
      })

      conn =
        conn
        |> assign(:current_user, user)
        |> get(Routes.account_path(conn, :index, filter: %{search: "viewed_user_last_name"}))

      assert html_response(conn, 200)
    end

    test "viewing an account", %{conn: conn} do
      user = TestHelpers.create_user(%{email: "current_user@example.com"})
      viewed_user = TestHelpers.create_user(%{email: "viewed_user@example.com"})

      conn =
        conn
        |> assign(:current_user, user)
        |> get(Routes.account_path(conn, :show, viewed_user.id))

      assert html_response(conn, 200)
    end
  end
end
