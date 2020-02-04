defmodule Web.SessionController do
  use Web, :controller

  alias ChallengeGov.Accounts
  alias ChallengeGov.LoginGov

  def new(conn, _params) do
    %{client_id: client_id, redirect_uri: redirect_uri, acr_value: acr_value} = oidc_config()

    case LoginGov.Cache.all() do
      %{authorization_endpoint: authorization_endpoint} ->
        authorization_url =
          LoginGov.build_authorization_url(
            client_id,
            acr_value,
            redirect_uri,
            authorization_endpoint
          )

        redirect(conn, external: authorization_url)

      _ ->
        conn
        |> put_flash(:error, "There was an issue logging in. Please try again.")
        |> put_status(400)
        |> render("new.html", error: "Something went wrong. Please try again.")
    end
  end

  def result(conn, %{"code" => code, "state" => _state}) do
    %{client_id: client_id, redirect_uri: redirect_uri} = oidc_config()

    %{
      end_session_endpoint: end_session_endpoint,
      token_endpoint: token_endpoint,
      private_key: private_key,
      public_key: public_key,
    } = LoginGov.Cache.all()

    with client_assertion <- LoginGov.build_client_assertion(client_id, token_endpoint, private_key),
         {:ok, %{"id_token" => id_token}} <- LoginGov.exchange_code_for_token(code, token_endpoint, client_assertion),
         {:ok, userinfo} <- LoginGov.decode_jwt(id_token, public_key) do

      IO.inspect userinfo
      {:ok, user} = case Accounts.get_by_email(userinfo["email"]) do
        {:error, :not_found} ->
          Accounts.create(%{
            email: userinfo["email"],
            password: "password",
            password_confirmation: "password",
            first_name: "Admin",
            last_name: "User",
            role: "admin",
            token: userinfo["sub"]
          })

        {:ok, account_user} ->
          {:ok, account_user}
      end

      conn
      |> put_flash(:info, "Login successful")
      # after you create a user above from the userinfo,
      # then store them in the session as the current_user
      |> put_session(:user_token, user.token)
      |> after_sign_in_redirect(Routes.page_path(conn, :index), user)
    else
      {:error, err} ->
        IO.inspect err

        conn
        |> put_flash(:error, "There was an issue logging in")
        |> put_status(400)
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def result(conn, %{"error" => error}) do
    conn
    |> put_flash(:info, "Login was cancelled")
    |> render("new.html")
  end

  def result(conn, _params) do
    conn
    |> put_flash(:info, "Please try again")
    |> render("new.html")
  end

  defp oidc_config do
    Application.get_env(:challenge_gov, :oidc_config)
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: Routes.challenge_path(conn, :index))
  end

  @doc """
  Redirect to the last seen page after being asked to sign in

  Or the home page
  """
  def after_sign_in_redirect(conn, default_path, user) do
    if user.role == "admin" do
      redirect(conn, to: Routes.admin_challenge_path(conn, :index))
    else
      case get_session(conn, :last_path) do
        nil ->
          redirect(conn, to: default_path)

        path ->
          conn
          |> put_session(:last_path, nil)
          |> redirect(to: path)
      end
    end
  end
end
