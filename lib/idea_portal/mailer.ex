defmodule IdeaPortal.Mailer do
  @moduledoc false

  use Bamboo.Mailer, otp_app: :idea_portal

  @doc """
  The email address that most emails will send from
  """
  def from() do
    IdeaPortal.config(Application.get_env(:idea_portal, __MODULE__)[:from])
  end
end
