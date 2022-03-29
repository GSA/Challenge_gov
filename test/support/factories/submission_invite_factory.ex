defmodule ChallengeGov.SubmissionInviteFactory do
  @moduledoc """
  Allows us to create a `ChallengeGov.Submissions.SubmissionInvite` in tests, seeds or manually in iex.
  """
  # credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
  defmacro __using__(_opts) do
    quote do
      def submission_invite_factory(attrs) do
        submission = attrs[:submission] || build(:submission)
        %ChallengeGov.Submissions.SubmissionInvite{
          submission: submission.id,
          message: attrs[:message] || "This is my submission message.",
          message_delta: attrs[:message_delta] || "Sure",
          status: attrs[:status] || "pending"
        }
      end
    end
  end
end
