defmodule ChallengeGov.Factory do
  @moduledoc """
  A meeting place for all of the factories.
  """
  use ExMachina.Ecto, repo: ChallengeGov.Repo

  use ChallengeGov.UserFactory
  use ChallengeGov.AgencyFactory
end
