defmodule Web.RegistrationControllerTest do
  use Web.ConnCase

  describe "creating a new account" do
    test "success", %{conn: conn} do
      params = %{
        email: "user@example.com",
        first_name: "John",
        last_name: "Smith",
        phone_number: "123-123-1234",
        password: "password",
        password_confirmation: "password"
      }

      conn = post(conn, Routes.registration_path(conn, :create), user: params)

      assert redirected_to(conn) == Routes.challenge_path(conn, :index)
    end

    test "failure", %{conn: conn} do
      params = %{
        email: "user@example.com"
      }

      conn = post(conn, Routes.registration_path(conn, :create), user: params)

      assert html_response(conn, 422)
    end
  end
end
