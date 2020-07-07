defmodule Web.AgencyView do
  use Web, :view

  alias ChallengeGov.Agencies
  alias ChallengeGov.Agencies.Avatar
  alias Web.FormView
  alias Web.SharedView
  alias Web.AgencyView
  alias Stein.Storage

  def name_link(conn, agency) do
    if agency do
      link(agency.name, to: Routes.agency_path(conn, :show, agency.id))
    end
  end

  def avatar_img(agency, opts \\ []) do
    case is_nil(agency) or is_nil(agency.avatar_key) do
      true ->
        url = Routes.static_path(Web.Endpoint, "/images/challenge-logo.png")
        opts = Keyword.merge([alt: "Challenge Logo"], opts)
        img_tag(url, opts)

      false ->
        url = Storage.url(Avatar.avatar_path(agency, "thumbnail"), signed: [expires_in: 3600])
        opts = Keyword.merge([alt: "Agency Logo"], opts)
        img_tag(url, opts)
    end
  end

  def avatar_url(agency) do
    case is_nil(agency) or is_nil(agency.avatar_key) do
      true ->
        Routes.static_path(Web.Endpoint, "/images/challenge-logo.png")

      false ->
        Storage.url(Avatar.avatar_path(agency, "original"), signed: [expires_in: 3600])
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

  def sub_agencies(%{sub_agencies: sub_agencies}), do: sub_agencies
  def sub_agencies(_agency), do: []
end
