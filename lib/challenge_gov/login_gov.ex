defmodule ChallengeGov.LoginGov do
  @moduledoc """
  Helper functions to sign in with LoginGov
  """

  use HTTPoison.Base

  alias ChallengeGov.LoginGov.Token

  # defp default_ssl_options() do
  #   [
  #     {:versions, [:"tlsv1.2", :"tlsv1.3"]},
  #     {:verify, :verify_none},
  #     {:cacertfile, :certifi.cacertfile()},
  #     {:depth, 10},
  #     {:customize_hostname_check,
  #      [
  #        match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
  #      ]}
  #   ]
  # end

  def get_well_known_configuration(idp_authorize_url) do
    # opts = [
    #   proxy:
    #     "https://0a46f47c-f501-495d-b615-4fbb5cfaa536:JaE9Ti0EttyeX9CkaqvGiq1XF+PP80YO@127.0.0.1:62443"
    # ]

    # options = [
    #   proxy:
    #     "https://0a46f47c-f501-495d-b615-4fbb5cfaa536:JaE9Ti0EttyeX9CkaqvGiq1XF+PP80YO@127.0.0.1:62443",
    #   insecure: true
    # ]

    # IO.inspect(:certifi.cacertfile(), label: " CERT  -------->")
    # IO.inspect(System.get_env("HTTPS_PROXY"), label: " This is the proxy -------->")

    # :hackney_trace.enable(:max, :io)
    request =
      get("https://www.google.gov", [],
        ssl: [
          {:verify, :verify_peer},
          {:cacertfile, "/etc/ssl/certs/ca-certificates.crt"},
          {:certfile, "/etc/ssl/certs/ca-certificates.crt"}
        ]
      )

    # now = DateTime.to_string(DateTime.utc_now())
    # IO.inspect(now, label: "Time: =======>")
    # IO.inspect(request, label: " <--------------------------")

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

  def process_response_headers() do
    [{"Content-type", "application/json"}]
  end

  # def process_request_options(options) do

  # [{:proxy, "https://0a46f47c-f501-495d-b615-4fbb5cfaa536:JaE9Ti0EttyeX9CkaqvGiq1XF+PP80YO@127.0.0.1:62443"},
  # ssl: [verify: :verify_none]
  # ]

  # [
  #   :proxy, {"https://0a46f47c-f501-495d-b615-4fbb5cfaa536:JaE9Ti0EttyeX9CkaqvGiq1XF+PP80YO@127.0.0.1", 62_443},
  #   :ssl {}
  #   # {:socks5_user, "0a46f47c-f501-495d-b615-4fbb5cfaa536"},
  #   # {:socks5_pass, "JaE9Ti0EttyeX9CkaqvGiq1XF+PP80YO"}
  # ]
  # end
  # def process_request_options(options) do
  #   ssl: [{:verify, :verify_peer}, {:cacertfile,  "/etc/ssl/certs/ca-certificates.crt"}, {:certfile,  "/etc/ssl/certs/ca-certificates.crt"}]
  #   [
  #     ssl_override: [
  #       certfile: "/etc/ssl/certs/ca-certificates.crt",
  #       cacertfile: "/etc/ssl/certs/ca-certificates.crt"
  #     ]
  #   ]
  # end

  def process_response_body(body) do
    Poison.decode!(body)
  end
end
