defmodule Web.SessionController do
  use Web, :controller

  alias ChallengeGov.Accounts

# from example app, trash this?:
    # def index(conn, _params) do
    #   render(conn, "index.html", acr_values: oidc_config(:acr_values))
    # end

  def new(conn, _params) do
    %{client_id: client_id, redirect_uri: redirect_uri, acr_value: acr_value} = oidc_config()

    case ChallengeGov.Cache.get_all() do
      %{authorization_endpoint: authorization_endpoint} ->
        authorization_url =
          ChallengeGov.build_authorization_url(
            client_id,
            acr_value,
            redirect_uri,
            authorization_endpoint
          )

        redirect(conn, external: authorization_url)

# from example app:
      # %{error: error} ->
      #   render(conn, "errors.html", error: error)

# changed to:
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "There was an issue logging in")
    end
  end

  def result(conn, %{"code" => code, "state" => _state}) do
    %{client_id: client_id, redirect_uri: redirect_uri} = oidc_config()

    %{
      end_session_endpoint: 'https://idp.int.identitysandbox.gov/openid_connect/logout',
      token_endpoint: 'https://idp.int.identitysandbox.gov/api/openid_connect/token',
      private_key: private_key,
      public_key: public_key,
      userinfo_endpoint: _userinfo_endpoint
    } = ChallengeGov.Cache.get_all()

    with client_assertion <-
           ChallengeGov.build_client_assertion(client_id, 'https://idp.int.identitysandbox.gov/api/openid_connect/token', private_key),
         {:ok, %{"id_token" => id_token, "access_token" => _access_token}} <-
           ChallengeGov.exchange_code_for_token(code, 'https://idp.int.identitysandbox.gov/api/openid_connect/token', client_assertion),
         userinfo <- ChallengeGov.decode_jwt(id_token, public_key),
         logout_uri <- ChallengeGov.build_logout_uri(id_token, 'https://idp.int.identitysandbox.gov/openid_connect/logout', redirect_uri) do
  # from example app:
      # render(conn, "success.html", userinfo: userinfo, logout_uri: logout_uri)
      conn
      |> put_flash(:error, "Login successful")
    else
  # from example app:
      # {:error, error} ->
      #   render(conn, "errors.html", error: error)
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "There was an issue logging in")
    end
  end

  def result(conn, %{"error" => error}) do
    render(conn, "errors.html", error: error)
  end

  def result(conn, _params) do
    render(conn, "errors.html", error: "missing callback param: code and/or state")
  end

  defp oidc_config(key) do
    oidc_config()[key]
  end

  defp oidc_config do
    Application.get_env(:challenge_gov, :oidc_config)
  end



  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case Accounts.validate_login(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "You have signed in.")
        |> put_session(:user_token, user.token)
        |> after_sign_in_redirect(Routes.challenge_path(conn, :index), user)

      {:error, :invalid} ->
        conn
        |> put_flash(:error, "Your email or password is invalid")
        |> redirect(to: Routes.session_path(conn, :new))
    end
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
