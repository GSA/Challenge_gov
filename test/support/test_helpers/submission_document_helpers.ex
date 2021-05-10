defmodule ChallengeGov.TestHelpers.SubmissionDocumentHelpers do
  @moduledoc """
  Helper factory functions for submission documents
  """
  alias ChallengeGov.SubmissionDocuments

  def upload_document(user, file_path, name \\ "") do
    {:ok, document} =
      SubmissionDocuments.upload(user, %{
        "file" => %{path: file_path},
        "name" => name
      })

    document
  end
end
