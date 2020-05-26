defmodule Web.ErrorView do
  use Web, :view

  def render("errors.json", %{changeset: changeset}) do
    errors =
      Enum.reduce(changeset.errors, %{}, fn {field, error}, errors ->
        error = translate_error(error)
        field_errors = Map.get(errors, field, [])
        Map.put(errors, field, [error | field_errors])
      end)

    %{errors: errors}
  end

  def render("500-fallthrough.html", _assigns) do
    "Something fell through and reached an error"
  end

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
