defmodule Web.TeamView do
  use Web, :view

  alias IdeaPortal.Teams
  alias Web.FormView

  def team_description(%{description: nil}), do: ""

  def team_description(team) do
    text_to_html(team.description)
  end
end
