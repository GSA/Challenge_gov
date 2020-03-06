defmodule ChallengeGov.Agencies.Agency do
  @moduledoc """
  Agency schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  alias ChallengeGov.Agencies.Member
  alias ChallengeGov.Challenges.Challenge
  alias ChallengeGov.Challenges.FederalPartner

  schema "agencies" do
    # Associations
    belongs_to(:parent, __MODULE__)
    has_many(:children, __MODULE__, foreign_key: :parent_id)
    has_many(:federal_partners, FederalPartner)
    has_many(:federal_partner_challenges, through: [:federal_partners, :challenge])

    # Fields
    field(:api_id, :integer)
    field(:name, :string)
    field(:description, :string)
    field(:deleted_at, :utc_datetime)

    field(:avatar_key, Ecto.UUID)
    field(:avatar_extension, :string)

    has_many(:members, Member)
    has_many(:challenges, Challenge)

    timestamps()
  end

  def create_changeset(struct, params) do
    struct
    |> cast(params, [:name, :description, :api_id, :parent_id])
    |> foreign_key_constraint(:api_id, name: :agencies_parent_id_fkey)
    |> validate_required([:name])
  end

  def update_changeset(struct, params) do
    struct
    |> cast(params, [:name, :description, :api_id, :parent_id])
    |> foreign_key_constraint(:api_id, name: :agencies_parent_id_fkey)
    |> validate_required([:name])
  end

  def avatar_changeset(struct, key, extension) do
    struct
    |> change()
    |> put_change(:avatar_key, key)
    |> put_change(:avatar_extension, extension)
  end
end
