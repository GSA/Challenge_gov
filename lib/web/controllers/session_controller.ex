defmodule Web.SessionController do
  use Web, :controller

  alias ChallengeGov.Accounts
  alias ChallengeGov.LoginGov

  def new(conn, _params) do
    conn
    |> assign(:changeset, Accounts.new())
    |> put_layout("session.html")
    |> render("new.html")
  end

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
      idp_authorize_url: idp_authorize_url
    } = oidc_config()

    {:ok, well_known_config} = LoginGov.get_well_known_configuration(idp_authorize_url)

    private_key = LoginGov.load_private_key(private_key_pass, private_key_path)
    {:ok, public_key} = LoginGov.get_public_key(well_known_config["jwks_uri"])
    token_endpoint = "https://idp.int.identitysandbox.gov/api/openid_connect/token"

    with client_assertion <-
           LoginGov.build_client_assertion(client_id, token_endpoint, private_key),
         {:ok, %{"id_token" => id_token}} <-
           LoginGov.exchange_code_for_token(code, token_endpoint, client_assertion),
         {:ok, userinfo} <- LoginGov.decode_jwt(id_token, public_key) do
      {:ok, user} =
        case Accounts.get_by_email(userinfo["email"]) do
          {:error, :not_found} ->
            Accounts.create(%{
              email: userinfo["email"],
              first_name: "Placeholder",
              last_name: "Placeholder",
              role: "admin",
              token: userinfo["sub"],
              terms_of_use: nil,
              privacy_guidelines: nil,
              pending: true
            })

          {:ok, account_user} ->
            case Map.get(account_user, :token) do
              nil ->
                Accounts.update(
                  account_user,
                  %{token: userinfo["sub"]}
                )

              _ ->
                {:ok, account_user}
            end
        end

      case user.suspended do
        true ->
          conn
          |> put_flash(:error, "Your account has been suspended")
          |> redirect(to: Routes.session_path(conn, :new))

        _ ->
          conn
          |> put_flash(:info, "Login successful")
          |> put_session(:user_token, user.token)
          |> after_sign_in_redirect(get_default_path(conn, user))
      end
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

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: Routes.session_path(conn, :new))
  end

  @doc """
  Assign redirect path based acceptance of terms
  """

  def get_default_path(conn, user) do
    if Accounts.has_accepted_terms?(user) do
      Routes.admin_challenge_path(conn, :index)
    else
      Routes.admin_terms_path(conn, :new)
    end
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
  def check_session_timeout(conn, opts) do
    timeout_at = get_session(conn, :session_timeout_at)

    if timeout_at && now() > timeout_at do
      logout_user(conn)
    else
      put_session(conn, :session_timeout_at, new_session_timeout_at(opts[:timeout_after_minutes]))
    end
  end

  defp logout_user(conn) do
    conn
    |> clear_session()
    |> configure_session([:renew])
    |> assign(:session_timeout, true)
    |> redirect(to: Routes.session_path(conn, :new))
  end

  defp now do
    DateTime.utc_now() |> DateTime.to_unix()
  end

  defp new_session_timeout_at(timeout_after_minutes) do
    now() + timeout_after_minutes * 60
  end
end
