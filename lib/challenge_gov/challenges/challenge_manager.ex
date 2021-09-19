defmodule ChallengeGov.Challenges.ChallengeManager do
  @moduledoc """
  ChallengeManager schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Accounts.User
  alias ChallengeGov.Challenges.Challenge

  @type t :: %__MODULE__{}

  schema "challenge_managers" do
    belongs_to(:challenge, Challenge)
    belongs_to(:user, User)
    field(:revoked_at, :utc_datetime)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :challenge_id,
      :user_id,
      :revoked_at
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
      :challenge_id,
      :revoked_at
    ])
  end
end
