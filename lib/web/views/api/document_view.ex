defmodule Web.Api.DocumentView do
  use Web, :view

  alias ChallengeGov.SupportingDocuments

  def render("show.json", %{document: document}) do
    %{
      id: document.id,
      name: document.name,
      section: document.section,
      filename: document.filename,
      display_name: Web.DocumentView.name(document),
      url: SupportingDocuments.download_document_url(document)
    }
  end

  def render("delete.json", _) do
    %{}
  end
end
