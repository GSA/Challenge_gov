defmodule Web.Api.SessionView do
  use Web, :view

  def render("success.json", %{new_timeout: new_timeout}) do
    %{"new_timeout" => new_timeout}
  end
end
