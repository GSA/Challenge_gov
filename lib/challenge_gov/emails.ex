defmodule ChallengeGov.Emails do
  @moduledoc """
  Container for emails that the ChallengeGov sends out
  """

  use Bamboo.Phoenix, view: Web.EmailView

  alias ChallengeGov.Mailer

  @doc """
  Send a email verification email
  """
  def verification_email(user) do
    base_email()
    |> to(user.email)
    |> subject("challenge.gov - Please verify your email address")
    |> assign(:user, user)
    |> render("verify-email.html")
  end

  @doc """
  Send an invite to a new user
  """
  def invitation_email(invitee_user, inviter_user) do
    base_email()
    |> to(invitee_user.email)
    |> subject("You've been invited to challenge.gov")
    |> assign(:invitee_user, invitee_user)
    |> assign(:inviter_user, inviter_user)
    |> render("invitation-email.html")
  end

  def team_invitation(invitee_user, team, inviter_user) do
    base_email()
    |> to(invitee_user.email)
    |> subject("You've been invited to join #{team.name} on challenge.gov")
    |> assign(:team, team)
    |> assign(:invitee_user, invitee_user)
    |> assign(:inviter_user, inviter_user)
    |> render("team-invitation.html")
  end

  @doc """
  Send a email verification email
  """
  def password_reset(user) do
    base_email()
    |> to(user.email)
    |> subject("challenge.gov - Password reset")
    |> assign(:user, user)
    |> render("password-reset.html")
  end

  @doc """
  Send an email about a new challenge being created
  """
  def new_challenge(challenge) do
    base_email()
    |> to("challenges@challenge.gov")
    |> subject("challenge.gov - New Challenge")
    |> assign(:challenge, challenge)
    |> render("new-challenge.html")
  end

  @doc """
  Send an email about a new challenge being rejected
  """
  def rejected_challenge(challenge) do
    base_email()
    |> to(challenge.submitter_email)
    |> subject("challenge.gov - Challenge Rejected")
    |> assign(:challenge, challenge)
    |> render("rejected-challenge.html")
  end

  def base_email() do
    new_email()
    |> from(Mailer.from())
  end
end
