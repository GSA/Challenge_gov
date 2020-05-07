defmodule ChallengeGov.TestHelpers.SolutionDocumentHelpers do
  @moduledoc """
  Helper factory functions for solution documents
  """
  alias ChallengeGov.SolutionDocuments

  def upload_document(user, file_path, name \\ "") do
    {:ok, document} =
      SolutionDocuments.upload(user, %{
        "file" => %{path: file_path},
        "name" => name
      })

    document
  end
end
