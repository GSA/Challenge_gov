defmodule ChallengeGov.PhaseFactory do
  @moduledoc """
  Allows us to create a `ChallengeGov.Challenges.Phase` in tests, seeds or manually in iex.
  """
  # credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
  defmacro __using__(_opts) do
    quote do
      def phase_factory(attrs) do
        challenge = attrs[:challenge] || insert(:challenge)
        %ChallengeGov.Challenges.Phase{
          judging_criteria: attrs[:judging_criteria] || "We may even read it!",
          judging_criteria_delta: attrs[:judging_criteria_delta] || "true",
          judging_criteria_length: attrs[:judging_criteria_length] || 100,
          how_to_enter_delta: attrs[:how_to_enter_delta] || "Right",
          open_to_submissions: attrs[:open_to_submissions] || true,
          how_to_enter: attrs[:how_to_enter] || "Push the buttons",
          how_to_enter_length: attrs[:how_to_enter_length] || 100,
          start_date: attrs[:start_date] || DateTime.utc_now(),
          delete_phase: attrs[:delete_phase] || false,
          end_date: attrs[:end_date] || nil,
          title: attrs[:title] || "Phase",
          challenge: challenge.id
        }
      end
    end
  end
end
