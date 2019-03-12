defmodule IdeaPortal.Challenges.Challenge do
  @moduledoc """
  User schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias IdeaPortal.Accounts.User
  alias IdeaPortal.SupportingDocuments.Document

  @type t :: %__MODULE__{}

  @focus_areas [
    "Housing",
    "Education",
    "Transportation",
    "Public Safety",
    "Health & Wellness",
    "Workforce Development"
  ]

  schema "challenges" do
    field(:focus_area, :string)
    field(:name, :string)
    field(:description, :string)
    field(:why, :string)

    belongs_to(:user, User)

    has_many(:supporting_documents, Document)

    timestamps()
  end

  @doc """
  List of all focus areas
  """
  def focus_areas(), do: @focus_areas

  def create_changeset(struct, params) do
    struct
    |> cast(params, [:focus_area, :name, :description, :why])
    |> validate_required([:focus_area, :name, :description, :why])
    |> validate_inclusion(:focus_area, @focus_areas)
  end
end
