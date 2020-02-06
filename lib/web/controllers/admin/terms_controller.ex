defmodule Web.Admin.TermsController do
  use Web, :controller

  alias ChallengeGov.Accounts

  def new(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> assign(:changeset, Accounts.edit(user))
    |> render("index.html")
  end

  def create(conn, params) do
    %{current_user: user} = conn.assigns

    if Map.get(params, "terms_and_conditions") === true do

      case Accounts.update(user, params) do
        {:ok, _user} ->
          conn
          |> put_flash(:info, "Your account has been updated")
          |> redirect(to: Routes.account_path(conn, :edit))

        {:error, changeset} ->
          conn
          |> put_flash(:error, "There was an issue updating your account")
          |> put_status(422)
          |> assign(:changeset, changeset)
          |> render("edit.html")
      end
    else
      conn
      |> put_flash(:info, "You must accept the terms and conditions to continue")
      |> render("index.html")
    end
  end

end
