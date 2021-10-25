defmodule Web.DocumentView do
  use Web, :view

  def render("show.json", %{document: document}) do
    Map.take(document, [:id, :filename])
  end

  def name(document) do
    if !is_nil(document.name) and document.name != "" do
      "#{document.name} (#{document.extension})"
    else
      "#{document.filename} (#{document.extension})"
    end
  end

  def name(document, name) do
    if !is_nil(name) and name != "" do
      "#{name}#{document.extension}"
    else
      "#{document.filename}"
    end
  end

  def filename(document) do
    if !is_nil(document.name) and document.name != "" do
      document.name
    else
      document.key
    end
  end
end
