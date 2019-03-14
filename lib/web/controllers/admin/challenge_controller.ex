defmodule Web.Admin.ChallengeController do
  use Web, :controller

  alias IdeaPortal.Challenges

  plug Web.Plugs.FetchPage when action in [:index]

  def index(conn, params) do
    %{page: page, per: per} = conn.assigns
    filter = Map.get(params, "filter", %{})
    pagination = Challenges.all(filter: filter, page: page, per: per)

    conn
    |> assign(:challenges, pagination.page)
    |> assign(:pagination, pagination.pagination)
    |> assign(:filter, filter)
    |> render("index.html")
  end

  def show(conn, %{"id" => id}) do
    with {:ok, challenge} <- Challenges.get(id) do
      conn
      |> assign(:challenge, challenge)
      |> render("show.html")
    end
  end
end
