defmodule Web.DocumentControllerTest do
  use Web.ConnCase

  describe "creating a new supporting document" do
    test "success", %{conn: conn} do
      user = TestHelpers.create_user()
      conn = assign(conn, :current_user, user)

      upload = %Plug.Upload{path: "test/fixtures/test.pdf", filename: "test.pdf"}

      conn = post(conn, Routes.document_path(conn, :create), document: %{file: upload})

      assert json_response(conn, 201)
    end

    test "failure", %{conn: conn} do
      user = TestHelpers.create_user()
      conn = assign(conn, :current_user, user)

      conn = post(conn, Routes.document_path(conn, :create), document: %{})

      assert json_response(conn, 422)
    end
  end
end
