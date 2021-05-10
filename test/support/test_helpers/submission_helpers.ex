defmodule ChallengeGov.TestHelpers.SubmissionHelpers do
  @moduledoc """
  Helper factory functions for submissions
  """
  alias ChallengeGov.Submissions
  alias ChallengeGov.Submissions.Submission
  alias ChallengeGov.Repo

  defp default_attributes(attributes) do
    Map.merge(
      %{
        "title" => "Test Title",
        "brief_description" => "Test Brief Description",
        "description" => "Test Description",
        "external_url" => "www.example.com"
      },
      attributes
    )
  end

  def create_draft_submission(attributes \\ %{}, user, challenge, phase \\ nil) do
    phase = phase || Enum.at(challenge.phases, 0)

    {:ok, submission} =
      %Submission{}
      |> Submission.draft_changeset(default_attributes(attributes), user, challenge, phase)
      |> Repo.insert()

    submission
  end

  def create_review_submission(attributes \\ %{}, user, challenge, phase \\ nil) do
    phase = phase || Enum.at(challenge.phases, 0)

    {:ok, submission} =
      %Submission{}
      |> Submission.review_changeset(default_attributes(attributes), user, challenge, phase)
      |> Repo.insert()

    submission
  end

  def create_submitted_submission(attributes \\ %{}, user, challenge, phase \\ nil) do
    phase = phase || Enum.at(challenge.phases, 0)

    {:ok, submission} =
      attributes
      |> create_review_submission(user, challenge, phase)
      |> Submissions.submit()

    submission
  end
end
