defmodule Web.Api.PhaseView do
  use Web, :view

  def render("show.json", %{phase: phase}) do
    %{
      id: phase.id,
      title: phase.title,
      start_date: phase.start_date,
      end_date: phase.end_date,
      open_to_submissions: phase.open_to_submissions,
      judging_criteria: HtmlSanitizeEx.basic_html(phase.judging_criteria),
      how_to_enter: HtmlSanitizeEx.basic_html(phase.how_to_enter)
    }
  end
end
