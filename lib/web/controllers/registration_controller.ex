defmodule Web.RegistrationController do
  use Web, :controller

  alias IdeaPortal.Accounts

  def new(conn, _params) do
    changeset = Accounts.new()

    conn
    |> assign(:changeset, changeset)
    |> put_layout("session.html")
    |> render("new.html")
  end

  def create(conn, %{"user" => params}) do
    case Accounts.register(params) do
      {:ok, user} ->
        message = "You will need to verify your email address before submitting a challenge."

        conn
        |> put_flash(:info, message)
        |> put_session(:user_token, user.token)
        |> redirect(to: Routes.challenge_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "There was an issue registering.")
        |> put_status(422)
        |> assign(:changeset, changeset)
        |> put_layout("session.html")
        |> render("new.html")
    end
  end
end
