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
