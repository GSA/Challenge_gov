defmodule ChallengeGov.Challenges.FederalPartner do
  @moduledoc """
  FederalPartner schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Agencies.Agency
  alias ChallengeGov.Challenges.Challenge

  @type t :: %__MODULE__{}

  schema "federal_partners" do
    belongs_to(:challenge, Challenge)
    belongs_to(:agency, Agency)
    belongs_to(:sub_agency, Agency)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :agency_id,
      :sub_agency_id,
      :challenge_id
    ])
    |> validate_required([
      :agency_id,
      :challenge_id
    ])
  end

  def draft_changeset(struct, params) do
    struct
    |> cast(params, [
      :agency_id,
      :sub_agency_id,
      :challenge_id
    ])
  end
end
