defmodule ChallengeGov.SavedChallenges.SavedChallenge do
  @moduledoc """
  SavedChallenge schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Accounts.User
  alias ChallengeGov.Challenges.Challenge

  @type t :: %__MODULE__{}
  schema "saved_challenges" do
    belongs_to(:user, User)
    belongs_to(:challenge, Challenge)

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(struct, user, challenge) do
    struct
    |> change()
    |> put_change(:user_id, user.id)
    |> put_change(:challenge_id, challenge.id)
    |> foreign_key_constraint(:user)
    |> foreign_key_constraint(:challenge)
    |> unique_constraint(:unique_user_challenge,
      name: :saved_challenges_user_id_challenge_id_index
    )
  end
end
