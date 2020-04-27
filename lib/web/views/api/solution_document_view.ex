defmodule Web.Api.SolutionDocumentView do
  use Web, :view

  alias ChallengeGov.SolutionDocuments

  def render("show.json", %{document: document}) do
    %{
      id: document.id,
      filename: document.filename,
      display_name: Web.DocumentView.name(document),
      url: SolutionDocuments.download_document_url(document)
    }
  end

  def render("delete.json", _) do
    %{}
  end
end
