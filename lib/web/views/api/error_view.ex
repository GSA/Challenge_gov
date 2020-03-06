defmodule Web.Api.ErrorView do
  use Web, :view

  def render("not_found.json", _params) do
    %{
      errors: "not_found"
    }
  end
end
