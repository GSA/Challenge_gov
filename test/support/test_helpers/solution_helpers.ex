defmodule ChallengeGov.TestHelpers.SolutionHelpers do
  @moduledoc """
  Helper factory functions for solutions
  """
  alias ChallengeGov.Solutions
  alias ChallengeGov.Solutions.Solution
  alias ChallengeGov.Repo

  defp default_attributes(attributes) do
    Map.merge(
      %{
        title: "Test Title",
        brief_description: "Test Brief Description",
        description: "Test Description",
        external_url: "www.example.com"
      },
      attributes
    )
  end

  def create_submitted_solution(attributes \\ %{}) do
    {:ok, solution} =
      %Solution{}
      |> Solution.submit_changeset(default_attributes(attributes))
      |> Repo.insert()

    solution
  end

  def create_draft_solution(attributes \\ %{}) do
    {:ok, solution} =
      %Solution{}
      |> Solution.draft_changeset(default_attributes(attributes))
      |> Repo.insert()

    solution
  end
end
