defmodule ChallengeGov.Emails do
  @moduledoc """
  Container for emails that the ChallengeGov sends out
  """

  use Bamboo.Phoenix, view: Web.EmailView

  # alias ChallengeGov.Mailer

  # defp base_email() do
  #   new_email()
  #   |> from(Mailer.from())
  # end
end
