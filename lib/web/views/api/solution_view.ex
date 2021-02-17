defmodule Web.Api.SolutionView do
  use Web, :view

  alias ChallengeGov.Solution
  alias Web.PhaseView  

  def render("judging_status.json", %{
        conn: conn,
        challenge: challenge,
        phase: phase,
        solution: solution,
        updated_solution: updated_solution,
        filter: filter
             }) do
    PhaseView.get_judging_status_button_values(
      conn,
      challenge,
      phase,
      updated_solution,
      solution.judging_status,
      filter
    )
  end
end
