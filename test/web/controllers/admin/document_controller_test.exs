defmodule Web.Admin.DocumentControllerTest do
  use Web.ConnCase

  describe "uploading and attaching a file" do
    test "success", %{conn: conn} do
      user = TestHelpers.create_user()
      challenge = TestHelpers.create_challenge(user)

      upload = %Plug.Upload{path: "test/fixtures/test.pdf", filename: "test.pdf"}
      params = [document: %{file: upload}]

      conn =
        conn
        |> assign(:current_user, %{user | role: "admin"})
        |> post(Routes.admin_challenge_document_path(conn, :create, challenge.id), params)

      assert redirected_to(conn) == Routes.admin_challenge_path(conn, :show, challenge.id)
    end

    test "failure", %{conn: conn} do
      user = TestHelpers.create_user()

      upload = %Plug.Upload{path: "test/fixtures/test.pdf", filename: "test.pdf"}

      conn =
        conn
        |> assign(:current_user, %{user | role: "admin"})
        |> post(Routes.admin_challenge_document_path(conn, :create, -1), document: %{file: upload})

      assert html_response(conn, 404)
    end
  end
end
