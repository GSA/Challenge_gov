defmodule ChallengeGov.Emails do
  @moduledoc """
  Container for emails that ChallengeGov sends out
  """

  use Bamboo.Phoenix, view: Web.EmailView

  alias ChallengeGov.Mailer

  def pending_challenge_email(challenge) do
    base_email()
    |> to("team@challenge.gov")
    |> subject("Challenge.gov - Challenge Review Needed")
    |> assign(:challenge, challenge)
    |> render("pending_challenge_email.html")
  end

  def challenge_rejection_email(user, challenge) do
    base_email()
    |> to(user.email)
    |> subject("Challenge.gov - Edits Requested: #{challenge.title}")
    |> assign(:challenge, challenge)
    |> assign(:message, challenge.rejection_message)
    |> render("challenge_rejection_email.html")
  end

  def challenge_submission(user, challenge) do
    base_email()
    |> to(user.email)
    |> subject("Challenge.gov - Your challenge has been submitted")
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

  def managed_submission_submission(user, _manager, submission) do
    base_email()
    |> to(user.email)
    |> subject("Challenge.gov - Submission created for #{submission.challenge.title}")
    |> assign(:submission, submission)
    |> assign(:challenge, submission.challenge)
    |> render("submission-submission-managed.html")
  end

  # might require a change in this email.
  def new_submission_submission(user, submission) do
    base_email()
    |> to(user.email)
    |> subject("Challenge.gov - Submission created for #{submission.challenge.title}")
    |> assign(:submission, submission)
    |> assign(:challenge, submission.challenge)
    |> render("submission_submission.html")
  end

  def submission_review(user, phase, submission) do
    base_email()
    |> to(user.email)
    |> subject("Challenge.gov - Action needed. New submission notification")
    |> assign(:submission, submission)
    |> assign(:phase, phase)
    |> render("managed_submission_created.html")
  end

  def submission_confirmation(submission) do
    base_email()
    |> to(submission.submitter.email)
    |> subject("Challenge.gov - Submission created for #{submission.challenge.title}")
    |> assign(:submission, submission)
    |> assign(:challenge, submission.challenge)
    |> render("submission_confirmation.html")
  end

  def days_deactivation_warning(user = %{role: "solver"}, days) when days == 10 do
    base_email()
    |> to(user.email)
    |> subject("Keep your Challenge.Gov account active - Log in today")
    |> assign(:days, days)
    |> render("solver_ten_day_deactivation_warning.html")
  end

  def days_deactivation_warning(user = %{role: "solver"}, days) when days == 5 do
    base_email()
    |> to(user.email)
    |> subject("Your Challenge.Gov account will be deactivated in 5 days")
    |> assign(:days, days)
    |> render("solver_five_day_deactivation_warning.html")
  end

  def days_deactivation_warning(user, days) when days == 10 do
    base_email()
    |> to(user.email)
    |> subject("Keep your Challenge.Gov account active - Log in today")
    |> assign(:days, days)
    |> render("ten_day_deactivation_warning.html")
  end

  def days_deactivation_warning(user, days) when days == 5 do
    base_email()
    |> to(user.email)
    |> subject("Your Challenge.Gov account will be deactivated in 5 days")
    |> assign(:days, days)
    |> render("five_day_deactivation_warning.html")
  end

  def one_day_deactivation_warning(user = %{role: "solver"}) do
    base_email()
    |> to(user.email)
    |> subject("Your account will be deactivated in 1 day - Log in today to keep it active")
    |> render("one_day_deactivation_warning.html")
  end

  def one_day_deactivation_warning(user) do
    base_email()
    |> to(user.email)
    |> subject("Your account will be deactivated in 1 day - Log in today to keep it active")
    |> render("one_day_deactivation_warning.html")
  end

  def contact(poc_email, challenge, public_email, body) do
    base_email()
    |> to(poc_email)
    |> subject("Challenge.gov - #{challenge.title}: Message from Public Visitor")
    |> put_header("Reply-To", public_email)
    |> assign(:public_email, public_email)
    |> assign(:challenge, challenge)
    |> assign(:body, body)
    |> render("contact.html")
  end

  def contact_confirmation(public_email, challenge, body) do
    base_email()
    |> to(public_email)
    |> subject("Challenge.gov - Challenge #{challenge.title}: Contact Confirmation")
    |> assign(:challenge, challenge)
    |> assign(:body, body)
    |> render("contact_confirmation.html")
  end

  def account_activation(user = %{role: "challenge_manager"}) do
    base_email()
    |> to(user.email)
    |> subject("Getting started with Challenge.Gov")
    |> render("account_activation_challenge_manager.html")
  end

  def account_activation(user = %{role: "solver"}) do
    base_email()
    |> to(user.email)
    |> subject("Getting started with Challenge.Gov")
    |> render("account_activation_solver.html")
  end

  def account_activation(user) do
    base_email()
    |> to(user.email)
    |> subject("Getting started with Challenge.Gov")
    |> render("account_activation_challenge_manager.html")
  end

  def account_reactivation(user) do
    base_email()
    |> to(user.email)
    |> subject("Your Challenge.Gov account has been reactivated")
    |> render("account_reactivation.html")
  end

  def submission_invite(submission_invite) do
    base_email()
    |> to(submission_invite.submission.submitter.email)
    |> subject(
      "Challenge.gov - You have been invited to the next phase of #{submission_invite.submission.challenge.title}"
    )
    |> assign(:submission_invite, submission_invite)
    |> assign(:challenge, submission_invite.submission.challenge)
    |> render("submission_invite.html")
  end

  def recertification_email(user) do
    base_email()
    |> to(user.email)
    |> subject("Your Challenge.Gov account has been recertified")
    |> render("account_recertification.html")
  end

  def one_day_recertification_email(user) do
    base_email()
    |> to(user.email)
    |> subject(
      "Your Challenge.Gov account will be deactivated in 1 day - Log in today to keep it active"
    )
    |> render("one_day_recertification.html")
  end

  def five_day_recertification_email(user) do
    base_email()
    |> to(user.email)
    |> subject("Action Needed - Log in to Challenge.Gov to recertify your account")
    |> render("five_day_recertification.html")
  end

  def fifteen_day_recertification_email(user) do
    base_email()
    |> to(user.email)
    |> subject("Recertify your Challenge.Gov account today")
    |> render("fifteen_day_recertification.html")
  end

  def thirty_day_recertification_email(user) do
    base_email()
    |> to(user.email)
    |> subject("It’s time for your annual Challenge.Gov account recertification")
    |> render("thirty_day_recertification.html")
  end

  def message_center_new_message(recipient_user, message) do
    base_email()
    |> to(recipient_user.email)
    |> subject("Challenge.Gov: You have a new message in your message center")
    |> assign(:message, message)
    |> render("message_center_new_message.html")
  end

  defp base_email() do
    new_email()
    |> from(Mailer.from())
  end
end
