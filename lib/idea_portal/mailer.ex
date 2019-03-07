defmodule IdeaPortal.Mailer do
  use Bamboo.Mailer, otp_app: :idea_portal

  @doc """
  The email address that most emails will send from
  """
  def from() do
    Application.get_env(:idea_portal, __MODULE__)[:from]
  end
end
