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

  def create_draft_solution(attributes \\ %{}, user, challenge) do
    {:ok, solution} =
      %Solution{}
      |> Solution.draft_changeset(default_attributes(attributes), user, challenge)
      |> Repo.insert()

    solution
  end

  def create_review_solution(attributes \\ %{}, user, challenge) do
    {:ok, solution} =
      %Solution{}
      |> Solution.review_changeset(default_attributes(attributes), user, challenge)
      |> Repo.insert()

    solution
  end

  def create_submitted_solution(attributes \\ %{}, user, challenge) do
    {:ok, solution} =
      attributes
      |> create_review_solution(user, challenge)
      |> Solutions.submit()

    solution
  end
end
