defmodule ChallengeGov.Recaptcha do
  @moduledoc """
  Integration with reCAPTCHA
  """

  @type token() :: String.t()

  @callback valid_token?(token()) :: tuple()

  @module Application.get_env(:challenge_gov, :recaptcha)[:module]

  @doc """
  Get the site key for recaptcha
  """
  def recaptcha_key() do
    ChallengeGov.config(Application.get_env(:challenge_gov, :recaptcha)[:key])
  end

  @doc """
  Check if a token is valid and not a bot
  """
  def valid_token?(token) do
    @module.valid_token?(token)
  end
end
