defmodule Web.AgencyView do
  use Web, :view

  alias ChallengeGov.Agencies
  alias ChallengeGov.Agencies.Avatar
  alias Stein.Storage

  def avatar_img(agency, opts \\ []) do
    case is_nil(agency) or is_nil(agency.avatar_key) do
      true ->
        path = Routes.static_path(Web.Endpoint, "/images/teams-card-logo.jpg")
        img_tag(path, alt: "Agency Logo")

      false ->
        url = Storage.url(Avatar.avatar_path(agency, "thumbnail"), signed: [expires_in: 3600])
        opts = Keyword.merge([alt: "Agency Logo"], opts)
        img_tag(url, opts)
    end
  end

  def team_description(%{description: nil}), do: ""

  def team_description(team) do
    text_to_html(team.description)
  end

  def current_team_member?(conn, team) do
    Map.has_key?(conn.assigns, :current_user) &&
      Agencies.member?(team, conn.assigns.current_user)
  end
end
