defmodule ChallengeGov.Challenges.ChallengeOwner do
  @moduledoc """
  ChallengeOwner schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Accounts.User
  alias ChallengeGov.Challenges.Challenge

  @type t :: %__MODULE__{}

  schema "challenge_owners" do
    belongs_to(:challenge, Challenge)
    belongs_to(:user, User)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :challenge_id,
      :user_id
    ])
    |> validate_required([
      :challenge_id,
      :user_id
    ])
  end

  def draft_changeset(struct, params) do
    struct
    |> cast(params, [
      :agency_id,
      :challenge_id
    ])
  end
end
