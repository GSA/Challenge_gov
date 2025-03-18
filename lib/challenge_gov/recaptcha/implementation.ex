defmodule ChallengeGov.Recaptcha.Implementation do
  @moduledoc false
  @behaviour ChallengeGov.Recaptcha
  alias ChallengeGov.HTTPClient

  @impl ChallengeGov.Recaptcha
  def valid_token?(token) do
    case recaptcha_request(token) do
      {:ok, %{"score" => score, "success" => true}} ->
        {:ok, score}

      resp ->
        resp
    end
  end

  defp recaptcha_request(token) do
    key = ChallengeGov.config(Application.get_env(:challenge_gov, :recaptcha)[:secret_key])

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    options = ChallengeGov.http_proxy_options()

    body = Plug.Conn.Query.encode(%{secret: key, response: token})

    case HTTPoison.post("https://www.google.com/recaptcha/api/siteverify", body, headers, options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Error: " <> inspect(reason)}

      _ ->
        {:error, "Unknown Recaptcha Failure"}
    end
  end
end
