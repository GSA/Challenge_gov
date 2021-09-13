defmodule Web.SiteContentController do
  use Web, :controller

  alias ChallengeGov.SiteContent
  alias ChallengeGov.Reports.Report
  alias ChallengeGov.Reports

  plug Web.Plugs.FetchPage when action in [:index]

  plug(
    Web.Plugs.EnsureRole,
    [:super_admin, :admin]
  )

  def index(conn, params) do
    %{current_user: user} = conn.assigns
    %{page: page, per: per} = conn.assigns

    filter = Map.get(params, "filter", %{})
    sort = Map.get(params, "sort", %{})

    [years, months, days] = Reports.generate_date_options()
    site_content = SiteContent.all(filter: filter, sort: sort, page: page, per: per)
    changeset = Report.changeset(%Report{}, %{"year" => nil, "month" => nil, "day" => nil})

    conn
    |> assign(:user, user)
    |> assign(:filter, filter)
    |> assign(:sort, sort)
    |> assign(:site_content, site_content.page)
    |> assign(:pagination, site_content.pagination)
    |> assign(:years, years)
    |> assign(:months, months)
    |> assign(:days, days)
    |> assign(:changeset, changeset)
    |> render("index.html")
  end

  def show(conn, %{"id" => section}) do
    %{current_user: user} = conn.assigns

    case SiteContent.get(section) do
      {:ok, content} ->
        conn
        |> assign(:user, user)
        |> assign(:content, content)
        |> render("show.html")

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Site content not found")
        |> redirect(to: Routes.site_content_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => section}) do
    %{current_user: user} = conn.assigns

    case SiteContent.get(section) do
      {:ok, content} ->
        conn
        |> assign(:user, user)
        |> assign(:content, content)
        |> assign(:changeset, SiteContent.edit(content))
        |> render("edit.html")

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Site content not found")
        |> redirect(to: Routes.site_content_path(conn, :index))
    end
  end

  def update(conn, %{"id" => section, "content" => params}) do
    %{current_user: user} = conn.assigns
    {:ok, content} = SiteContent.get(section)

    case SiteContent.update(content, params) do
      {:ok, _content} ->
        conn
        |> assign(:user, user)
        |> put_flash(:info, "Site content updated")
        |> redirect(to: Routes.site_content_path(conn, :show, section))

      {:error, changeset} ->
        conn
        |> assign(:content, content)
        |> assign(:changeset, changeset)
        |> put_flash(:error, "Content could not be saved")
        |> put_status(422)
        |> render("edit.html")
    end
  end
end
