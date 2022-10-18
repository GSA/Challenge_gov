defmodule Web.SessionController do
  use Web, :controller

  alias ChallengeGov.Accounts
  alias ChallengeGov.LoginGov
  alias ChallengeGov.Security
  alias ChallengeGov.SecurityLogs

  def new(conn, params) do
    conn
    |> assign(:changeset, Accounts.new())
    |> put_layout("session.html")
    |> maybe_put_flash(params)
    |> render("new.html")
  end

  def maybe_put_flash(conn, %{"inactive" => "true"}),
    do: put_flash(conn, :error, "You have been logged off due to inactivity")

  def maybe_put_flash(conn, _), do: conn

  def create(conn, _params) do
    %{
      client_id: client_id,
      redirect_uri: redirect_uri,
      acr_value: acr_value,
      idp_authorize_url: idp_authorize_url
    } = oidc_config()

    authorization_url =
      LoginGov.build_authorization_url(
        client_id,
        acr_value,
        redirect_uri,
        idp_authorize_url
      )

    redirect(conn, external: authorization_url)
  end

  def result(conn, %{"code" => code, "state" => _state}) do
    %{
      client_id: client_id,
      private_key_password: private_key_pass,
      private_key_path: private_key_path,
      idp_authorize_url: idp_authorize_url,
      token_endpoint: token_endpoint
    } = oidc_config()

    {:ok, well_known_config} = LoginGov.get_well_known_configuration(idp_authorize_url)

    private_key = LoginGov.load_private_key(private_key_pass, private_key_path)
    {:ok, public_key} = LoginGov.get_public_key(well_known_config["jwks_uri"])

    with client_assertion <-
           LoginGov.build_client_assertion(client_id, token_endpoint, private_key),
         {:ok, %{"id_token" => id_token}} <-
           LoginGov.exchange_code_for_token(code, token_endpoint, client_assertion),
         {:ok, userinfo} <- LoginGov.decode_jwt(id_token, public_key) do
      {:ok, user} = Accounts.map_from_login(userinfo, id_token, Security.extract_remote_ip(conn))

      conn
      |> put_session(:user_token, user.token)
      |> put_session(:session_timeout_at, new_session_timeout_at(Security.timeout_interval()))
      |> after_sign_in_redirect(Routes.dashboard_path(conn, :index))
    else
      {:error, _err} ->
        conn
        |> put_flash(:error, "There was an issue logging in")
        |> redirect(to: Routes.session_path(conn, :new))
    end
  end

  def result(conn, %{"error" => error}) do
    if error == "access_denied" do
      conn
      |> put_flash(:info, "Login cancelled")
      |> render("new.html")
    else
      conn
      |> put_flash(:info, "There was an issue with logging in. Please try  again.")
      |> render("new.html")
    end
  end

  def result(conn, _params) do
    conn
    |> put_flash(:info, "Please try again")
    |> render("new.html")
  end

  defp oidc_config do
    Application.get_env(:challenge_gov, :oidc_config)
  end

  @empty_jwt_token ""
  def delete(conn = %{assigns: %{current_user: user}}, _params) do
    %{
      client_id: client_id
    } = oidc_config()

    Accounts.update_active_session(user, false, @empty_jwt_token)
    log_session_duration(conn, user)

    conn
    |> clear_session()
    |> redirect(external: LoginGov.logout_uri(client_id))
  end

  @doc """
  Redirect to the last seen page after being asked to sign in

  Or the home page
  """
  def after_sign_in_redirect(conn, default_path) do
    case get_session(conn, :last_path) do
      nil ->
        redirect(conn, to: default_path)

      path ->
        conn
        |> put_session(:last_path, nil)
        |> redirect(to: path)
    end
  end

  @doc """
  session timeout and reset
  """
  def check_session_timeout(conn, _opts_or_params) do
    timeout_at = get_session(conn, :session_timeout_at)
    timeout_after_minutes = Security.timeout_interval()

    if timeout_at do
      if now() < timeout_at do
        put_session(
          conn,
          :session_timeout_at,
          new_session_timeout_at(timeout_after_minutes)
        )
      else
        conn
        |> logout_user()
        |> halt()
      end
    else
      conn
      |> logout_user()
      |> halt()
    end
  end

  def logout_user(conn = %{assigns: %{current_user: user}}) do
    Accounts.update_active_session(user, false, @empty_jwt_token)

    log_session_duration(conn, user)

    conn
    |> clear_session()
    |> configure_session([:renew])
    |> assign(:session_timeout, true)
    |> redirect(to: Routes.session_path(conn, :new))
  end

  defp now do
    DateTime.utc_now() |> DateTime.to_unix()
  end

  def new_session_timeout_at(timeout_after_minutes) do
    now() + timeout_after_minutes * 60
  end

  defp log_session_duration(conn, user) do
    SecurityLogs.log_session_duration(
      user,
      Timex.to_unix(Timex.now()),
      Security.extract_remote_ip(conn)
    )
  end
end
