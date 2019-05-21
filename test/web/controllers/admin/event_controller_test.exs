defmodule Web.Admin.EventControllerTest do
  use Web.ConnCase

  describe "creating a new event" do
    test "success", %{conn: conn} do
      user = TestHelpers.create_user()
      challenge = TestHelpers.create_challenge(user)

      params = %{
        title: "Created",
        body: "A body",
        occurs_on: "2019-05-01"
      }

      conn =
        conn
        |> assign(:current_user, %{user | role: "admin"})
        |> post(Routes.admin_challenge_event_path(conn, :create, challenge.id), event: params)

      assert redirected_to(conn) == Routes.admin_challenge_path(conn, :show, challenge.id)
    end

    test "failure", %{conn: conn} do
      user = TestHelpers.create_user()
      challenge = TestHelpers.create_challenge(user)

      params = %{
        title: "Created",
        body: "A body"
      }

      conn =
        conn
        |> assign(:current_user, %{user | role: "admin"})
        |> post(Routes.admin_challenge_event_path(conn, :create, challenge.id), event: params)

      assert html_response(conn, 422)
    end
  end

  describe "updating an event" do
    test "success", %{conn: conn} do
      user = TestHelpers.create_user()
      challenge = TestHelpers.create_challenge(user)
      event = TestHelpers.create_event(challenge)

      params = %{title: "Updated"}

      conn =
        conn
        |> assign(:current_user, %{user | role: "admin"})
        |> put(Routes.admin_event_path(conn, :update, event.id), event: params)

      assert redirected_to(conn) == Routes.admin_challenge_path(conn, :show, challenge.id)
    end

    test "failure", %{conn: conn} do
      user = TestHelpers.create_user()
      challenge = TestHelpers.create_challenge(user)
      event = TestHelpers.create_event(challenge)

      params = %{title: nil}

      conn =
        conn
        |> assign(:current_user, %{user | role: "admin"})
        |> put(Routes.admin_event_path(conn, :update, event.id), event: params)

      assert html_response(conn, 422)
    end
  end
end
