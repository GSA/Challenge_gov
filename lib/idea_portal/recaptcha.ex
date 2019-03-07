defmodule IdeaPortal.Recaptcha do
  @moduledoc """
  Integration with reCAPTCHA
  """

  @type token() :: String.t()

  @callback valid_token?(token()) :: boolean()

  @module Application.get_env(:idea_portal, :recaptcha)[:module]

  @doc """
  Check if a token is valid and not a bot
  """
  def valid_token?(token) do
    @module.valid_token?(token)
  end
end
