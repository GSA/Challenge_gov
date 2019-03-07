defmodule IdeaPortal.Recaptcha.Implementation do
  @moduledoc """
  Implementation details for Recaptcha
  """

  @behaviour IdeaPortal.Recaptcha

  @impl true
  def valid_token?(token) do
    case recaptcha_request(token) do
      {:ok, %{"success" => true}} ->
        true

      _ ->
        false
    end
  end

  defp recaptcha_request(token) do
    key = IdeaPortal.config(Application.get_env(:idea_portal, :recaptcha)[:secret_key])

    body = {:form, [secret: key, response: token]}

    response = HTTPoison.post("https://www.google.com/recaptcha/api/siteverify", body)

    case response do
      {:ok, %{body: body, status_code: 200}} ->
        {:ok, Jason.decode!(body)}

      _ ->
        :error
    end
  end
end
