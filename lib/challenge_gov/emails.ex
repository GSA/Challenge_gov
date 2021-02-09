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

  def challenge_submission(user, challenge) do
    base_email()
    |> to(user.email)
    |> subject("Challenge.gov - Your challenge has been received")
    |> assign(:challenge, challenge)
    |> render("challenge_submission.html")
  end

  def challenge_auto_published(user, challenge) do
    base_email()
    |> to(user.email)
    |> subject("Challenge.gov - Your challenge has been auto published")
    |> assign(:challenge, challenge)
    |> render("challenge_auto_publish.html")
  end

  def managed_solution_submission(user, manager, solution) do
    base_email()
    |> to(user.email)
    |> subject(
      "Challenge.gov - Solution submitted for #{solution.challenge.id} #{solution.challenge.title}"
    )
    |> assign(:solution, solution)
    |> assign(:challenge, solution.challenge)
    |> render("solution-submission-managed.html")
  end

  # might require a change in this email.
  def new_solution_submission(user, solution) do
    base_email()
    |> to(user.email)
    |> subject(
      "Challenge.gov - Solution submitted for #{solution.challenge.id} #{solution.challenge.title}"
    )
    |> assign(:solution, solution)
    |> assign(:challenge, solution.challenge)
    |> render("solution-submission.html")
  end

  def solution_review(user, phase, solution) do
    base_email()
    |> to(user.email)
    |> subject(
      "Action needed. New submission notification"
    )
    |> assign(:solution, solution)
    |> assign(:phase, phase)
    |> render("managed-solution-created.html")
  end

  def solution_confirmation(solution) do
    base_email()
    |> to(solution.submitter.email)
    |> subject(
      "Challenge.gov - Solution submitted for #{solution.challenge.id} #{solution.challenge.title}"
    )
    |> assign(:solution, solution)
    |> assign(:challenge, solution.challenge)
    |> render("solution-confirmation.html")
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

  def contact(poc_email, challenge, public_email, body) do
    base_email()
    |> to(poc_email)
    |> subject("Challenge #{challenge.id}: Question from Public Visitor")
    |> put_header("Reply-To", public_email)
    |> assign(:public_email, public_email)
    |> assign(:challenge, challenge)
    |> assign(:body, body)
    |> render("contact.html")
  end

  def contact_confirmation(public_email, challenge, body) do
    base_email()
    |> to(public_email)
    |> subject("Challenge #{challenge.id}: Contact Confirmation")
    |> assign(:challenge, challenge)
    |> assign(:body, body)
    |> render("contact_confirmation.html")
  end

  def submission_invite(submission_invite) do
    base_email()
    |> to(submission_invite.solution.submitter.email)
    |> subject(
      "You have been invited to the next phase of #{submission_invite.solution.challenge.title}"
    )
    |> assign(:submission_invite, submission_invite)
    |> assign(:challenge, submission_invite.solution.challenge)
    |> render("submission_invite.html")
  end

  defp base_email() do
    new_email()
    |> from(Mailer.from())
  end
end
