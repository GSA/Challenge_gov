defmodule ChallengeGov.TestHelpers.AgencyHelpers do
  @moduledoc """
  Helper factory functions for agencies
  """
  alias ChallengeGov.Agencies
  alias ChallengeGov.Repo

  defp default_attributes(attributes) do
    Map.merge(
      %{
        name: "Test Agency",
        description: "Test desription for an agency"
      },
      attributes
    )
  end

  def create_agency(attributes \\ %{}) do
    {:ok, agency} =
      %Agencies.Agency{}
      |> Agencies.Agency.create_changeset(default_attributes(attributes))
      |> Repo.insert()

    agency
  end
end
