defmodule Web.DocumentView do
  use Web, :view

  def render("show.json", %{document: document}) do
    Map.take(document, [:id, :filename])
  end

  def name(document) do
    if !is_nil(document.name) and document.name != "" do
      "#{document.filename} (#{document.name})"
    else
      document.filename
    end
  end
end
