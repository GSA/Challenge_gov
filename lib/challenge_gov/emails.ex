defmodule ChallengeGov.Emails do
  @moduledoc """
  Container for emails that ChallengeGov sends out
  """

  use Bamboo.Phoenix, view: Web.EmailView

  alias ChallengeGov.Mailer

  def challenge_rejection_email(user, challenge) do
    base_email()
    |> to(user.email)
    |> subject(
      "Challenge.gov - Edits have been requested to your challenge: ##{challenge.id} #{
        challenge.title
      }"
    )
    |> assign(:challenge, challenge)
    |> assign(:message, challenge.rejection_message)
    |> render("challenge-rejection-email.html")
  end

  defp base_email() do
    new_email()
    |> from(Mailer.from())
  end
end
