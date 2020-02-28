defmodule ChallengeGov.SupportingDocuments.Document do
  @moduledoc """
  Document schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Accounts.User
  alias ChallengeGov.Challenges.Challenge

  @type t :: %__MODULE__{}

  @sections [
    "resources",
    "judging",
    "rules"
  ]

  schema "supporting_documents" do
    belongs_to(:user, User)
    belongs_to(:challenge, Challenge)

    field(:filename, :string)
    field(:key, Ecto.UUID)
    field(:extension, :string)
    field(:section, :string, default: "resources")

    timestamps()
  end

  def create_changeset(struct, file, key) do
    struct
    |> change()
    |> put_change(:filename, file.filename)
    |> put_change(:key, key)
    |> put_change(:extension, file.extension)
  end

  def challenge_changeset(struct, challenge, section) do
    struct
    |> change()
    |> put_change(:challenge_id, challenge.id)
    |> put_change(:section, section)
    |> foreign_key_constraint(:challenge_id)
  end

  def sections, do: @sections
end
