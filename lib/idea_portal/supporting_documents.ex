defmodule IdeaPortal.SupportingDocuments do
  @moduledoc """
  Context for managing supporting documents on a challenge
  """

  alias IdeaPortal.SupportingDocuments.Document
  alias IdeaPortal.Repo
  alias Stein.Storage

  @doc """
  Get the storage path for a document
  """
  def document_path(key, extension), do: "/documents/#{key}#{extension}"

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

    case Storage.upload(file, path, extensions: [".doc", ".pdf"], meta: meta) do
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
  Attach a document to a challenge

  Must be:
  - Not attached to a challenge
  - Same user owns both the challenge and document
  """
  def attach_to_challenge(document = %{challenge_id: challenge_id}, _challenge)
      when challenge_id != nil do
    document
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.add_error(:challenge_id, "already assigned")
    |> Ecto.Changeset.apply_action(:update)
  end

  def attach_to_challenge(document, challenge) do
    case document.user_id == challenge.user_id do
      true ->
        document
        |> Document.challenge_changeset(challenge)
        |> Repo.update()

      false ->
        document
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:challenge_id, "not yours")
        |> Ecto.Changeset.apply_action(:update)
    end
  end
end
