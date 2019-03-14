defmodule IdeaPortal.SupportingDocuments.Document do
  @moduledoc """
  Document schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias IdeaPortal.Accounts.User
  alias IdeaPortal.Challenges.Challenge

  @type t :: %__MODULE__{}

  schema "supporting_documents" do
    field(:filename, :string)
    field(:key, Ecto.UUID)
    field(:extension, :string)

    belongs_to(:user, User)
    belongs_to(:challenge, Challenge)

    timestamps()
  end

  def create_changeset(struct, file, key) do
    struct
    |> change()
    |> put_change(:filename, file.filename)
    |> put_change(:key, key)
    |> put_change(:extension, file.extension)
  end

  def challenge_changeset(struct, challenge) do
    struct
    |> change()
    |> put_change(:challenge_id, challenge.id)
    |> foreign_key_constraint(:challenge_id)
  end
end
