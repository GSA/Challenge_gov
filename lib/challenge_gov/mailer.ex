defmodule ChallengeGov.Mailer do
  @moduledoc false

  use Bamboo.Mailer, otp_app: :challenge_gov

  @doc """
  The email address that most emails will send from
  """
  def from() do
    ChallengeGov.config(Application.get_env(:challenge_gov, __MODULE__)[:from])
  end
end
