defmodule Web.EmailView do
  use Web, :view

  alias Web.AccountView
  alias Web.Endpoint

  def password_reset_url(user) do
    Routes.registration_reset_url(Endpoint, :edit, token: user.password_reset_token)
  end

  def verification_url(user) do
    Routes.registration_verify_url(Endpoint, :show, token: user.email_verification_token)
  end

  def invite_url(user) do
    Routes.user_invite_accept_url(Endpoint, :new, token: user.email_verification_token)
  end
end
