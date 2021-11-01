defmodule Web.AgencyController do
  use Web, :controller

  alias ChallengeGov.Agencies

  plug(Web.Plugs.EnsureRole, [:super_admin, :admin])
  plug(Web.Plugs.FetchPage when action in [:index])

  action_fallback(Web.FallbackController)

  def index(conn, params) do
    %{current_user: user} = conn.assigns
    %{page: page, per: per} = conn.assigns
    filter = Map.get(params, "filter", %{})
    sort = Map.get(params, "sort", %{})

    %{page: parent_agencies, pagination: pagination} =
      Agencies.all_highest_level(filter: filter, page: page, per: per)

    conn
    |> assign(:user, user)
    |> assign(:agencies, parent_agencies)
    |> assign(:filter, filter)
    |> assign(:sort, sort)
    |> assign(:pagination, pagination)
    |> render("index.html")
  end

  def show(conn, %{"id" => id}) do
    with {:ok, agency} <- Agencies.get(id) do
      conn
      |> assign(:agency, agency)
      |> assign(:members, agency.members)
      |> render("show.html")
    end
  end

  def new(conn, params) do
    parent_id = Map.get(params, "id", nil)

    conn
    |> assign(:changeset, Agencies.new())
    |> assign(:parent_id, parent_id)
    |> render("new.html")
  end

  def create(conn, %{"agency" => params}) do
    %{current_user: user} = conn.assigns

    case Agencies.create(user, params) do
      {:ok, agency} ->
        conn
        |> put_flash(:info, "Agency created!")
        |> redirect(to: Routes.agency_path(conn, :show, agency.id))

      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> put_status(422)
        |> render("new.html")
    end
  end

  def edit(conn, %{"id" => id}) do
    with {:ok, agency} <- Agencies.get(id) do
      conn
      |> assign(:agency, agency)
      |> assign(:changeset, Agencies.edit(agency))
      |> render("edit.html")
    end
  end

  def update(conn, %{"id" => id, "agency" => params}) do
    {:ok, agency} = Agencies.get(id)

    case Agencies.update(agency, params) do
      {:ok, agency} ->
        conn
        |> put_flash(:info, "Agency updated!")
        |> redirect(to: Routes.agency_path(conn, :show, agency.id))

      {:error, changeset} ->
        conn
        |> assign(:agency, agency)
        |> assign(:changeset, changeset)
        |> put_flash(:error, "Agency could not be saved")
        |> put_status(422)
        |> render("edit.html")
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, agency} <- Agencies.get(id),
         {:ok, _agency} <- Agencies.delete(agency) do
      conn
      |> put_flash(:info, "Agency deleted!")
      |> redirect(to: Routes.agency_path(conn, :index))
    end
  end

  def remove_logo(conn, %{"id" => id}) do
    with {:ok, agency} <- Agencies.get(id),
         {:ok, agency} <- Agencies.remove_logo(agency) do
      conn
      |> put_flash(:info, "Logo removed")
      |> redirect(to: Routes.agency_path(conn, :show, agency.id))
    end
  end
end
