defmodule Web.RegistrationVerifyController do
  use Web, :controller

  alias IdeaPortal.Accounts

  def show(conn, %{"token" => token}) do
    with {:ok, user} <- Accounts.verify_email(token) do
      conn
      |> put_flash(:info, "Your email has been verified.")
      |> put_session(:user_token, user.token)
      |> redirect(to: Routes.page_path(conn, :index))
    else
      _ ->
        conn
        |> put_flash(:error, "There was an issue with your token. Please try again.")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
