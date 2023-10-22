defmodule ChallengeGov.LoginGov do
  @moduledoc """
  Helper functions to sign in with LoginGov
  """

  use HTTPoison.Base

  alias ChallengeGov.LoginGov.Token

  def get_well_known_configuration(idp_authorize_url) do
    idp_authorize_url
    |> uri_join("/.well-known/openid-configuration")
    |> get()
    |> handle_response("Sorry, could not fetch well known configuration")
  end

  def get_public_key(jwks_uri) do
    jwks_uri
    |> get()
    |> handle_response("Sorry, could not fetch public key")
    |> case do
      {:ok, body} -> {:ok, body |> Map.fetch!("keys") |> List.first()}
      foo -> foo
    end
  end

  def exchange_code_for_token(code, token_endpoint, jwt) do
    body = %{
      grant_type: "authorization_code",
      code: code,
      client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
      client_assertion: jwt
    }

    token_endpoint
    |> post(Poison.encode!(body), [{"Content-Type", "application/json"}])
    |> handle_response("Sorry, could not exchange code")
  end

  def get_user_info(userinfo_endpoint, access_token) do
    userinfo_endpoint
    |> get([{"Authorization", "Bearer " <> access_token}])
    |> handle_response("Sorry, could not fetch userinfo")
  end

  def build_authorization_url(client_id, acr_values, redirect_uri, idp_authorize_url) do
    query = [
      client_id: client_id,
      response_type: "code",
      acr_values: acr_values,
      scope: "openid email",
      redirect_uri: uri_join(redirect_uri, "/auth/result"),
      state: random_value(),
      nonce: random_value(),
      prompt: "select_account"
    ]

    idp_authorize_url <> "?" <> URI.encode_query(query)
  end

  def build_client_assertion(client_id, token_endpoint, private_key) do
    claims = %{
      iss: client_id,
      sub: client_id,
      aud: token_endpoint,
      jti: random_value(),
      nonce: random_value(),
      exp: DateTime.to_unix(DateTime.utc_now()) + 1000
    }

    Token.generate_and_sign!(claims, Token.signer(private_key))
  end

  def load_private_key(nil, private_key_path) do
    JOSE.JWK.from_pem_file(private_key_path)
  end

  def load_private_key(password, private_key_path) do
    JOSE.JWK.from_pem_file(password, private_key_path)
  end

  def decode_jwt(id_token, public_key) do
    Token.verify(id_token, Token.signer(public_key))
  end

  def logout_uri(id_token) do
    %{logout_uri: logout_uri, logout_redirect_uri: logout_redirect_uri} =
      Application.get_env(:challenge_gov, :login_gov_logout)

    logout_uri <>
      "?" <>
      URI.encode_query(
        client_id: id_token,
        post_logout_redirect_uri: logout_redirect_uri
      )
  end

  defp handle_response(response, msg) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "#{msg}: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "#{msg}: #{reason}"}
    end
  end

  defp random_value do
    :crypto.strong_rand_bytes(16)
    |> Base.encode16(case: :lower)
  end

  defp uri_join(uri, path) do
    uri
    |> URI.merge(path)
    |> URI.to_string()
  end

  def process_response_body(body) do
    Poison.decode!(body)
  end
end
