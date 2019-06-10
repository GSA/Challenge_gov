defmodule IdeaPortal.Emails do
  @moduledoc """
  Container for emails that the IdeaPortal sends out
  """

  use Bamboo.Phoenix, view: Web.EmailView

  alias IdeaPortal.Mailer

  @doc """
  Send a email verification email
  """
  def verification_email(user) do
    base_email()
    |> to(user.email)
    |> subject("City Backlog - Please verify your email address")
    |> assign(:user, user)
    |> render("verify-email.html")
  end

  @doc """
  Send an invite to a new user
  """
  def invitation_email(invitee_user, inviter_user) do
    base_email()
    |> to(invitee_user.email)
    |> subject("You've been invited to City Backlog")
    |> assign(:invitee_user, invitee_user)
    |> assign(:inviter_user, inviter_user)
    |> render("invitation-email.html")
  end

  def team_invitation(invitee_user, team, inviter_user) do
    base_email()
    |> to(invitee_user.email)
    |> subject("You've been invited to join #{team.name} on City Backlog")
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
    |> subject("City Backlog - Password reset")
    |> assign(:user, user)
    |> render("password-reset.html")
  end

  def base_email() do
    new_email()
    |> from(Mailer.from())
  end
end
