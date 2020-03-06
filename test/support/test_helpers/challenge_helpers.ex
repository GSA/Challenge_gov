defmodule ChallengeGov.TestHelpers.ChallengeHelpers do
  @moduledoc """
  Helper factory functions for challenges
  """
  alias ChallengeGov.Challenges
  alias ChallengeGov.Repo

  def create_challenge(attributes \\ %{}) do
    {:ok, challenge} =
      %Challenges.Challenge{}
      |> Challenges.Challenge.changeset(attributes)
      |> Repo.insert()

    challenge
  end
end
