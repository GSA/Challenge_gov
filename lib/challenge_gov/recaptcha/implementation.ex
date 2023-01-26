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

    body = Plug.Conn.Query.encode(%{secret: key, response: token})

    request = Finch.build(:post, "https://www.google.com/recaptcha/api/siteverify", headers, body)

    case Finch.request(request, HTTPClient) do
      {:ok, %{body: body, status: 200}} ->
        {:ok, Jason.decode!(body)}

      {:error, failure} ->
        {:error, "Error: " <> inspect(failure)}

      _ ->
        {:error, "Unknown Recaptcha Failure"}
    end
  end
end
