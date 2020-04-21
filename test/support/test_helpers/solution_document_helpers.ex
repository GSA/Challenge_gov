defmodule ChallengeGov.TestHelpers.SolutionDocumentHelpers do
  @moduledoc """
  Helper factory functions for solution documents
  """
  alias ChallengeGov.SolutionDocuments

  def upload_document(user, file_path) do
    {:ok, document} =
      SolutionDocuments.upload(user, %{
        "file" => %{path: file_path}
      })

    document
  end
end
