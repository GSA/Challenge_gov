defmodule Web.PageController do
  use Web, :controller
# previously in this file:
  # def index(conn, _params) do
  #   conn
  #   |> render("index.html")
  # end

  def index(conn, _params) do
    render(conn, "index.html", acr_values: oidc_config(:acr_values))
  end

  def oidc(conn, %{"acr_value" => acr_value}) do
    %{client_id: client_id, redirect_uri: redirect_uri} = oidc_config()

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
end
