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

  def edit_title(agency) do
    if agency.parent do
      "Edit Component:"
    else
      "Edit Agency:"
    end
  end

  def new_title(parent_id) do
    if parent_id do
      {:ok, parent} = Agencies.get(parent_id)
      "Add Component: #{parent.name}"
    else
      "New Agency"
    end
  end

  def avatar_img(agency, opts \\ []) do
    case is_nil(agency) or is_nil(agency.avatar_key) do
      true ->
        url = Routes.static_url(Web.Endpoint, "/images/challenge-logo-2_1.svg")
        opts = Keyword.merge([alt: "Challenge Logo"], opts)
        img_tag(url, opts)

      false ->
        url = Storage.url(Avatar.avatar_path(agency, "original"), signed: [expires_in: 3600])
        opts = Keyword.merge([alt: "Agency Logo", style: "max-height: 200px"], opts)
        img_tag(url, opts)
    end
  end

  def avatar_url(agency) do
    case is_nil(agency) or is_nil(agency.avatar_key) do
      true ->
        Routes.static_url(Web.Endpoint, "/images/challenge-logo-2_1.svg")

      false ->
        Storage.url(Avatar.avatar_path(agency, "original"), signed: [expires_in: 3600])
    end
  end

  def active_component_agencies(component_agencies) do
    component_agencies
    |> Enum.filter(fn ca -> is_nil(ca.deleted_at) end)
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
