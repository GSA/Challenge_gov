defmodule ChallengeGov.SubmissionFactory do
  @moduledoc """
  Allows us to create a `ChallengeGov.Submissions.Submission` in tests, seeds or manually in iex.
  """
  # credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
  defmacro __using__(_opts) do
    quote do
      def submission_factory(attrs) do
        manager = attrs[:manager] || insert(:user)
        phase = attrs[:phase] || insert(:phase)
        submitter = attrs[:submitter] || insert(:user)
        invite = attrs[:invite] || insert(:submission_invite)

        %ChallengeGov.Submissions.Submission{
          brief_description: attrs[:brief_description] || "I didn't do any real work on this.",
          brief_description_delta: attrs[:brief_description_delta] || "sure",
          brief_description_length: attrs[:brief_description_length] || 100,
          description: attrs[:description] || "Tired of writing these.",
          judging_status: attrs[:judging_status] || "not_selected",
          external_url: attrs[:external_url] || "www.google.com",
          description_delta: attrs[:description_delta] || "ok",
          invite: invite.id,
          title: attrs[:title] || sequence("Please pick me!"),
          challenge: attrs[:challenge] || build(:challenge),
          review_verified: attrs[:review_verified] || true,
          terms_accepted: attrs[:terms_accepted] || true,
          status: attrs[:status] || "submitted",
          deleted_at: attrs[:deleted_at] || nil,
          submitter: submitter.id,
          manager: manager.id,
          phase: phase.id
      }
      end
    end
  end
end
