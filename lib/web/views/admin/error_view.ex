defmodule Web.Admin.ErrorView do
  use Web, :view

  def render("500-fallthrough.html", _assigns) do
    "Something fell through and reached an error"
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
