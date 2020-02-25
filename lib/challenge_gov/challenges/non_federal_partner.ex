defmodule ChallengeGov.Challenges.NonFederalPartner do
  @moduledoc """
  NonFederalPartner schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Challenges.Challenge

  @type t :: %__MODULE__{}

  schema "non_federal_partners" do
    belongs_to(:challenge, Challenge)
    field(:name, :string)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :name
    ])
    |> validate_required([
      :name
    ])
    |> foreign_key_constraint(:challenge_id)
  end

  def draft_changeset(struct, params) do
    struct
    |> cast(params, [
      :name
    ])
    |> foreign_key_constraint(:challenge_id)
  end
end
