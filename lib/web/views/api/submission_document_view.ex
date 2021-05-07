defmodule Web.Api.SubmissionDocumentView do
  use Web, :view

  alias ChallengeGov.SubmissionDocuments

  def render("show.json", %{document: document}) do
    %{
      id: document.id,
      filename: document.filename,
      display_name: Web.DocumentView.name(document),
      url: SubmissionDocuments.download_document_url(document)
    }
  end

  def render("delete.json", _) do
    %{}
  end
end
