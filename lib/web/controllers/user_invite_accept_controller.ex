defmodule Web.UserInviteAcceptController do
  use Web, :controller

  alias ChallengeGov.Accounts

  def new(conn, %{"token" => token}) do
    conn
    |> assign(:token, token)
    |> assign(:changeset, Accounts.new())
    |> render("new.html")
  end

  def create(conn, %{"token" => token, "user" => params}) do
    case Accounts.finalize_invitation(token, params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome!")
        |> put_session(:user_token, user.token)
        |> redirect(to: Routes.challenge_path(conn, :index))

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "There was an error finalizing your account.")
        |> put_status(422)
        |> assign(:token, token)
        |> assign(:changeset, Accounts.new())
        |> render("new.html")

      {:error, changeset} ->
        conn
        |> assign(:token, token)
        |> assign(:changeset, changeset)
        |> put_flash(:error, "There was an error finalizing your account.")
        |> put_status(422)
        |> render("new.html")
    end
  end
end
