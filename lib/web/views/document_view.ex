defmodule Web.DocumentView do
  use Web, :view

  def render("show.json", %{document: document}) do
    Map.take(document, [:id, :filename])
  end
end
