defmodule Web.AccountController do
  use Web, :controller

  alias IdeaPortal.Accounts

  def edit(conn, _params) do
    user = conn.assigns.current_user

    conn
    |> assign(:changeset, Accounts.edit(user))
    |> render("edit.html")
  end

  def update(conn, %{"user" => params}) do
    user = conn.assigns.current_user

    case Accounts.update(user, params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Your account has been updated")
        |> put_session(:user_token, user.token)
        |> redirect(to: Routes.account_path(conn, :edit))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "There was an issue updating your account")
        |> put_status(422)
        |> assign(:changeset, changeset)
        |> render("edit.html")
    end
  end
end
