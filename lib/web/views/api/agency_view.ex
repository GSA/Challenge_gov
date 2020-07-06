defmodule Web.Api.AgencyView do
  use Web, :view

  alias Web.Api.PaginationView

  def render("index.json", assigns = %{agencies: agencies, pagination: _pagination}) do
    %{
      collection: render_many(agencies, __MODULE__, "show.json", assigns),
      pagination: render(PaginationView, "pagination.json", assigns)
    }
  end

  def render("index.json", %{agencies: agencies}) do
    render_many(agencies, __MODULE__, "show.json")
  end

  def render("show.json", %{agency: agency}) do
    %{
      id: agency.id,
      name: agency.name
    }
  end
end
