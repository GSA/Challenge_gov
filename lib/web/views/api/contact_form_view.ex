defmodule Web.Api.ContactFormView do
  use Web, :view

  def render("success.json", _) do
    %{
      message: "Your message has been received"
    }
  end
end
