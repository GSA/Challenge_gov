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
  Upload a new supporting document
  """
  def upload(user, %{"file" => file}) do
    file = Storage.prep_file(file)

    key = UUID.uuid4()
    extension = Path.extname(file.path)

    path = document_path(key, extension)

    case Storage.upload(file, path, extensions: [".doc", ".pdf"]) do
      :ok ->
        user
        |> Ecto.build_assoc(:supporting_documents)
        |> Document.create_changeset(key, extension)
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
end
