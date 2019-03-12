defmodule IdeaPortal.SupportingDocuments.Document do
  @moduledoc """
  Document schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias IdeaPortal.Accounts.User

  @type t :: %__MODULE__{}

  schema "supporting_documents" do
    field(:key, Ecto.UUID)
    field(:extension, :string)

    belongs_to(:user, User)

    timestamps()
  end

  def create_changeset(struct, key, extension) do
    struct
    |> change()
    |> put_change(:key, key)
    |> put_change(:extension, extension)
  end
end
