defmodule ChallengeGov.Agencies.Agency do
  @moduledoc """
  Agency schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Agencies.Member
  alias ChallengeGov.Challenges.Challenge
  alias ChallengeGov.Challenges.FederalPartner

  @type t :: %__MODULE__{}

  schema "agencies" do
    # Associations
    belongs_to(:parent, __MODULE__)
    has_many(:sub_agencies, __MODULE__, foreign_key: :parent_id)
    has_many(:federal_partners, FederalPartner)
    has_many(:federal_partner_challenges, through: [:federal_partners, :challenge])
    has_many(:members, Member)
    has_many(:challenges, Challenge)

    # Fields
    field(:acronym, :string)
    field(:created_on_import, :boolean)
    field(:description, :string)
    field(:deleted_at, :utc_datetime)
    field(:name, :string)

    # Images
    field(:avatar_key, Ecto.UUID)
    field(:avatar_extension, :string)

    # Misc
    timestamps(type: :utc_datetime_usec)
  end

  def create_changeset(struct, params) do
    struct
    |> cast(params, [
      :acronym,
      :created_on_import,
      :description,
      :name,
      :parent_id
    ])
    |> validate_required([:name, :acronym])
  end

  def update_changeset(struct, params) do
    struct
    |> cast(params, [
      :acronym,
      :description,
      :name,
      :parent_id
    ])
    |> validate_required([:name, :acronym])
  end

  def avatar_changeset(struct, key, extension) do
    struct
    |> change()
    |> put_change(:avatar_key, key)
    |> put_change(:avatar_extension, extension)
  end
end
