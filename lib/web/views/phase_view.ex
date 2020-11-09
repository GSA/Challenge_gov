defmodule Web.PhaseView do
  use Web, :view

  alias ChallengeGov.Phases
  alias Web.SharedView

  def status(phase) do
    cond do
      Phases.is_past?(phase) ->
        content_tag(:span, "Closed to submissions")

      Phases.is_current?(phase) ->
        content_tag(:span, "Open to submissions")

      Phases.is_future?(phase) ->
        [
          content_tag(:span, "Opens on "),
          SharedView.local_datetime_tag(phase.start_date, "span")
        ]
    end
  end
end
