defmodule ChallengeGov.SavedChallenges.SavedChallenge do
  @moduledoc """
  SavedChallenge schema
  """

  alias ChallengeGov.Accounts.User
  alias ChallengeGov.Challenges.Challenge

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}
  schema "saved_challenges" do
    belongs_to(:user, User)
    belongs_to(:challenge, Challenge)

    timestamps()
  end

  def changeset(struct, user, challenge) do
    struct
    |> change()
    |> put_change(:user_id, user.id)
    |> put_change(:challenge_id, challenge.id)
    |> foreign_key_constraint(:user)
    |> foreign_key_constraint(:challenge)
  end
end
