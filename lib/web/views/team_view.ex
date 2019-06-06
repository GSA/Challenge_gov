defmodule Web.TeamView do
  use Web, :view

  alias IdeaPortal.Teams
  alias IdeaPortal.Teams.Avatar
  alias Stein.Storage
  alias Web.AccountView
  alias Web.FormView

  def avatar_img(team, opts \\ []) do
    case is_nil(team.avatar_key) do
      true ->
        path = Routes.static_path(Web.Endpoint, "/images/teams-card-logo.jpg")
        img_tag(path, alt: "Team Avatar")

      false ->
        opts = Keyword.merge([alt: "Team Avatar"], opts)
        img_tag(Storage.url(Avatar.avatar_path(team, "thumbnail")), opts)
    end
  end

  def team_description(%{description: nil}), do: ""

  def team_description(team) do
    text_to_html(team.description)
  end
end
