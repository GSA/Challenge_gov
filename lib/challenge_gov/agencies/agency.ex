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
    has_many(:federal_partners, FederalPartner)
    has_many(:federal_partner_challenges, through: [:federal_partners, :challenge])

    # Fields
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
    |> cast(params, [:name, :description])
    |> validate_required([:name])
  end

  def update_changeset(struct, params) do
    struct
    |> cast(params, [:name, :description])
    |> validate_required([:name])
  end

  def avatar_changeset(struct, key, extension) do
    struct
    |> change()
    |> put_change(:avatar_key, key)
    |> put_change(:avatar_extension, extension)
  end
end
