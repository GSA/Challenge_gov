defmodule ChallengeGov.Emails do
  @moduledoc """
  Container for emails that ChallengeGov sends out
  """

  use Bamboo.Phoenix, view: Web.EmailView

  alias ChallengeGov.Mailer

  def pending_challenge_email(challenge) do
    base_email()
    |> to("team@challenge.gov")
    |> subject("Challenge Review Needed")
    |> assign(:challenge, challenge)
    |> render("pending-challenge-email.html")
  end

  def challenge_rejection_email(user, challenge) do
    base_email()
    |> to(user.email)
    |> subject("Challenge.gov - Edits Requested: ##{challenge.id} #{challenge.title}")
    |> assign(:challenge, challenge)
    |> assign(:message, challenge.rejection_message)
    |> render("challenge-rejection-email.html")
  end

  def days_deactivation_warning(user, days) do
    base_email()
    |> to(user.email)
    |> subject("Challenge.gov - Account will be deactivated in #{days} days")
    |> assign(:days, days)
    |> render("days_deactivation_warning.html")
  end

  def one_day_deactivation_warning(user) do
    base_email()
    |> to(user.email)
    |> subject("Challenge.gov - Account will be deactivated in 1 day")
    |> render("one_day_deactivation_warning.html")
  end

  defp base_email() do
    new_email()
    |> from(Mailer.from())
  end
end
