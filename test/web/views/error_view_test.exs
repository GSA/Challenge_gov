defmodule Web.ErrorViewTest do
  use Web.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  alias ChallengeGov.Accounts
  alias Web.ErrorView

  describe "errors.json" do
    test "renders changeset errors" do
      changeset =
        %Accounts.User{}
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:email, "can't be blank")

      json = ErrorView.render("errors.json", %{changeset: changeset})
      assert json == %{errors: %{email: ["can't be blank"]}}
    end
  end

  test "renders 404.html" do
    assert render_to_string(Web.ErrorView, "404.html", []) == "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(Web.ErrorView, "500.html", []) == "Internal Server Error"
  end
end
