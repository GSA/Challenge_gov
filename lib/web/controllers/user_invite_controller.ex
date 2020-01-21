defmodule Web.UserInviteController do
  use Web, :controller

  alias ChallengeGov.Accounts

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => params}) do
    %{current_user: user} = conn.assigns

    case Accounts.invite(user, params) do
      {:ok, _new_user} ->
        conn
        |> put_flash(:info, "Thanks for inviting a someone to help out!")
        |> redirect(to: Routes.challenge_path(conn, :index))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "There was a problem sending the invitation.")
        |> redirect(to: Routes.user_invite_path(conn, :new))
    end
  end
end
