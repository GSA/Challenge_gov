defmodule Web.RegistrationView do
  use Web, :view

  alias Web.FormView

  def recaptcha_key() do
    Application.get_env(:idea_portal, :recaptcha)[:key]
  end
end
