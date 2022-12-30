defmodule ChallengeGov.Recaptcha.Implementation do
  @moduledoc """
  Implementation details for Recaptcha
  """

  @behaviour ChallengeGov.Recaptcha

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

    response = Mojito.post("https://www.google.com/recaptcha/api/siteverify", headers, body)

    case response do
      {:ok, %{body: body, status_code: 200}} ->
        {:ok, Jason.decode!(body)}

      {:error, %Mojito.Error{message: nil, reason: reason}} ->
        {:error, reason}

      _ ->
        {:error, "Unknown Recaptcha Failure"}
    end
  end
end
