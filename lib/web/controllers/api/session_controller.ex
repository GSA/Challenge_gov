defmodule Web.Api.SessionController do
  use Web, :controller

  alias ChallengeGov.Accounts
  alias ChallengeGov.Security
  alias ChallengeGov.SecurityLogs
  alias ChallengeGov.LoginGov.Token

  plug :fetch_session when action in [:check_session_timeout, :logout_user]

  def check_session_timeout(conn, opts) do
    timeout_at = get_session(conn, :session_timeout_at)
    timeout_after_minutes = opts[:timeout_after_minutes] || Security.timeout_interval()
    new_timeout = new_session_timeout_at(timeout_after_minutes)

    if timeout_at && now() > timeout_at do
      logout_user(conn, opts)
    else
      conn
      |> put_session(:session_timeout_at, new_timeout)
      |> assign(:new_timeout, new_timeout)
      |> render("success.json")
    end
  end

  @empty_jwt_token ""
  def logout_user(conn, _opts) do
    %{current_user: user} = conn.assigns
    Accounts.update_active_session(user, false, @empty_jwt_token)

    SecurityLogs.log_session_duration(
      user,
      Timex.to_unix(Timex.now()),
      Security.extract_remote_ip(conn)
    )

    conn
    |> clear_rails_session()
    |> clear_session()
    |> configure_session([:renew])
    |> assign(:session_timeout, true)
    |> redirect(to: Routes.session_path(conn, :new))
  end

  def external_login(conn, _opts) do
    verify_external_login_request(conn)
  end

  defp verify_external_login_request(conn) do
    login_secret = conn |> get_req_header("login-secret") |> List.first()
    remote_ip = conn |> get_req_header("remote-ip") |> List.first()

    if login_secret == System.get_env("LOGIN_SECRET") do
      with user_jwt <- conn |> get_req_header("user-jwt") |> List.first(),
           {:ok, userinfo = %{"sub" => id_token}} <- verify_user_jwt(user_jwt),
           {:ok, user} <-
             Accounts.map_from_login(userinfo, id_token, remote_ip) do
        conn
        |> put_session(:user_token, user.token)
        |> put_session(:session_timeout_at, new_session_timeout_at(Security.timeout_interval()))
        |> assign(:current_user, user)
        |> send_resp(200, "Success")
      else
        _ -> send_resp(conn, 401, "Unauthorized")
      end
    else
      send_resp(conn, 401, "Unauthorized")
    end
  end

  defp verify_user_jwt(jwt) do
    signer = Joken.Signer.create("HS256", System.get_env("JWT_SECRET"))

    case Token.verify_and_validate(jwt, signer) do
      {:ok, claims} -> {:ok, claims}
      {:error, _} -> {:error, "Invalid JWT"}
    end
  end

  defp now do
    DateTime.utc_now() |> DateTime.to_unix()
  end

  defp new_session_timeout_at(timeout_after_minutes) do
    now() + timeout_after_minutes * 60
  end

  defp clear_rails_session(conn) do
    delete_resp_cookie(conn, "_rails_new_session")
  end
end
