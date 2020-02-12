defmodule Web.Admin.AgencyView do
  use Web, :view

  alias Web.Admin.FormView
  alias Web.SharedView
  alias Web.AgencyView  
  
  def name_link(conn, agency) do
    link(agency.name, to: Routes.admin_agency_path(conn, :show, agency.id))
  end
end
