defmodule ChallengeGov.SubmissionDocuments do
  @moduledoc """
  Context for managing documents on a submission
  """

  alias ChallengeGov.Submissions.Document
  alias ChallengeGov.Repo
  alias Stein.Storage

  @doc """
  Get the storage path for a document
  """
  def document_path(key, extension), do: "/documents/#{key}#{extension}"

  def document_path(document = %Document{}) do
    document_path(document.key, document.extension)
  end

  @doc """
  Get a signed URL to view the document
  """
  def download_document_url(document) do
    Storage.url(document_path(document.key, document.extension), signed: [expires_in: 3600])
  end

  @doc """
  Get a submission document
  """
  def get(id) do
    case Repo.get(Document, id) do
      nil ->
        {:error, :not_found}

      document ->
        {:ok, document}
    end
  end

  @doc """
  Upload a new submission document
  """
  def upload(user, params = %{"file" => file}) do
    file = Storage.prep_file(file)

    key = UUID.uuid4()
    path = document_path(key, file.extension)

    meta = [
      {:content_disposition, ~s{attachment; filename="#{file.filename}"}}
    ]

    allowed_extensions = [".pdf", ".txt", ".csv", ".jpg", ".png", ".tiff"]

    case Storage.upload(file, path, meta: meta, extensions: allowed_extensions) do
      :ok ->
        user
        |> Ecto.build_assoc(:submission_documents)
        |> Document.create_changeset(file, key, params["name"])
        |> Repo.insert()

      {:error, _reason} ->
        user
        |> Ecto.build_assoc(:submission_documents)
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:file, "had an issue uploading")
        |> Ecto.Changeset.apply_action(:insert)
    end
  end

  def upload(user, _) do
    user
    |> Ecto.build_assoc(:submission_documents)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.add_error(:file, "can't be blank")
    |> Ecto.Changeset.apply_action(:insert)
  end

  @doc """
  Delete a document

  Also removes the file from remote storage
  """
  def delete(document) do
    case Stein.Storage.delete(document_path(document)) do
      :ok ->
        Repo.delete(document)

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Attach a document to a submission

  Must be:
  - Not attached to a submission
  - Same user owns both the submission and document
  """
  def attach_to_submission(document, submission, name \\ nil)

  def attach_to_submission(document = %{submission_id: submission_id}, _submission, _name)
      when submission_id != nil do
    document
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.add_error(:submission_id, "already assigned")
    |> Ecto.Changeset.apply_action(:update)
  end

  def attach_to_submission(document, submission, _name) do
    case document.user_id == submission.submitter_id do
      true ->
        document
        |> Document.submission_changeset(submission)
        |> Repo.update()

      false ->
        document
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:submission_id, "not yours")
        |> Ecto.Changeset.apply_action(:update)
    end
  end
end
