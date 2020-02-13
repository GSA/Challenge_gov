defmodule Web.Admin.AgencyController do
  use Web, :controller

  alias ChallengeGov.Agencies

  plug(Web.Plugs.FetchPage when action in [:index])

  action_fallback(Web.Admin.FallbackController)

  def index(conn, params) do
    %{page: page, per: per} = conn.assigns
    filter = Map.get(params, "filter", %{})
    %{page: agencies, pagination: pagination} = Agencies.all(filter: filter, page: page, per: per)

    conn
    |> assign(:agencies, agencies)
    |> assign(:filter, filter)
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
  
  def new(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> assign(:changeset, Agencies.new())
    |> render("new.html")
  end

  def create(conn, %{"agency" => params}) do
    %{current_user: user} = conn.assigns

    case Agencies.create(user, params) do
      {:ok, agency} ->
        conn
        |> put_flash(:info, "Agency created!")
        |> redirect(to: Routes.admin_agency_path(conn, :show, agency.id))

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
        |> redirect(to: Routes.admin_agency_path(conn, :show, agency.id))

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
      |> redirect(to: Routes.admin_agency_path(conn, :index))
    end
  end

  def remove_logo(conn, %{"id" => id}) do
    with {:ok, agency} <- Agencies.get(id),
         {:ok, agency} <- Agencies.remove_logo(agency) do
      conn
      |> put_flash(:info, "Logo removed")
      |> redirect(to: Routes.admin_agency_path(conn, :show, agency.id))
    end
  end
end
