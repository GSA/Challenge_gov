defmodule ChallengeGov.Factory do
  @moduledoc """
  A meeting place for all of the factories.
  """
  use ExMachina.Ecto, repo: ChallengeGov.Repo

  use ChallengeGov.UserFactory
  use ChallengeGov.PhaseFactory
  use ChallengeGov.AgencyFactory
  use ChallengeGov.MemberFactory
  use ChallengeGov.ChallengeFactory
  use ChallengeGov.SubmissionFactory
  use ChallengeGov.SubmissionInviteFactory
end
