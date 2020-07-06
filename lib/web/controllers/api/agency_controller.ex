defmodule Web.Api.AgencyController do
  use Web, :controller

  alias ChallengeGov.Agencies
  alias Web.Api.ErrorView

  def sub_agencies(conn, %{"agency_id" => id}) do
    with {id, _} <- Integer.parse(id),
         {:ok, agency} <- Agencies.get(id) do
      conn
      |> assign(:agencies, agency.sub_agencies)
      |> render("index.json")
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> put_view(ErrorView)
        |> render("not_found.json")
    end
  end
end
