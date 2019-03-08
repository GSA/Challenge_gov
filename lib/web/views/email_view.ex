defmodule Web.EmailView do
  use Web, :view

  alias Web.Endpoint

  def verification_url(user) do
    Routes.registration_verify_url(Endpoint, :show, token: user.email_verification_token)
  end
end
