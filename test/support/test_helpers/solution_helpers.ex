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

  def create_draft_solution(attributes \\ %{}, user, challenge, phase \\ nil) do
    phase = phase || Enum.at(challenge.phases, 0)

    {:ok, solution} =
      %Solution{}
      |> Solution.draft_changeset(default_attributes(attributes), user, challenge, phase)
      |> Repo.insert()

    solution
  end

  def create_review_solution(attributes \\ %{}, user, challenge, phase \\ nil) do
    phase = phase || Enum.at(challenge.phases, 0)

    {:ok, solution} =
      %Solution{}
      |> Solution.review_changeset(default_attributes(attributes), user, challenge, phase)
      |> Repo.insert()

    solution
  end

  def create_submitted_solution(attributes \\ %{}, user, challenge, phase \\ nil) do
    phase = phase || Enum.at(challenge.phases, 0)

    {:ok, solution} =
      attributes
      |> create_review_solution(user, challenge, phase)
      |> Solutions.submit()

    solution
  end
end
