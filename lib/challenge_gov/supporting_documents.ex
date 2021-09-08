defmodule ChallengeGov.SupportingDocuments do
  @moduledoc """
  Context for managing supporting documents on a challenge
  """

  alias ChallengeGov.SupportingDocuments.Document
  alias ChallengeGov.Repo
  alias Stein.Storage

  @doc """
  Get available sections for a document
  """
  def sections, do: Document.sections()

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
  Get a supporting document
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
  Upload a new supporting document
  """
  def upload(user, %{"file" => file}) do
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
        |> Ecto.build_assoc(:supporting_documents)
        |> Document.create_changeset(file, key)
        |> Repo.insert()

      {:error, _reason} ->
        user
        |> Ecto.build_assoc(:supporting_documents)
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:file, "had an issue uploading")
        |> Ecto.Changeset.apply_action(:insert)
    end
  end

  def upload(user, _) do
    user
    |> Ecto.build_assoc(:supporting_documents)
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
  Attach a document to a challenge

  Must be:
  - Not attached to a challenge
  - Same user owns both the challenge and document
  """
  def attach_to_challenge(document = %{challenge_id: challenge_id}, _challenge, _section, _name)
      when challenge_id != nil do
    document
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.add_error(:challenge_id, "already assigned")
    |> Ecto.Changeset.apply_action(:update)
  end

  def attach_to_challenge(document, challenge, section, name) do
    case document.user_id == challenge.user_id do
      true ->
        document
        |> Document.challenge_changeset(challenge, section, name)
        |> Repo.update()

      false ->
        document
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:challenge_id, "not yours")
        |> Ecto.Changeset.apply_action(:update)
    end
  end
end
