defmodule Web.Api.SubmissionView do
  use Web, :view

  alias Web.PhaseView

  def render("judging_status.json", %{
        conn: conn,
        challenge: challenge,
        phase: phase,
        submission: submission,
        updated_submission: updated_submission,
        filter: filter
      }) do
    PhaseView.get_judging_status_button_values(
      conn,
      challenge,
      phase,
      updated_submission,
      submission.judging_status,
      filter
    )
  end
end
