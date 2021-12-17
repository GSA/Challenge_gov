defmodule Web.PageController do
  use Web, :controller

  alias ChallengeGov.Accounts

  def index(conn, _params) do
    conn
    |> render("index.html")
  end

  def dev_accounts(conn, _params) do
    conn
    |> put_layout("session.html")
    |> render("dev_accounts.html")
  end

  def dev_account_sign_in(conn, %{"email" => email}) do
    case Accounts.get_by_email(email) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Login successful")
        |> put_session(:user_token, user.token)
        |> put_session(
          :session_timeout_at,
          Web.SessionController.new_session_timeout_at(ChallengeGov.Security.timeout_interval())
        )
        |> redirect(to: Routes.dashboard_path(conn, :index))

      {:error, _err} ->
        conn
        |> put_flash(:error, "There was an issue logging in")
        |> redirect(to: Routes.session_path(conn, :new))
    end
  end
end
