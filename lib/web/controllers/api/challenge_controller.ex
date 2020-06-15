defmodule Web.Api.ChallengeController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias Web.Api.ErrorView

  plug Web.Plugs.FetchPage when action in [:index]

  def index(conn, _params) do
    %{page: page, per: per} = conn.assigns

    %{page: page, pagination: pagination} = Challenges.all(page: page, per: per)

    conn
    |> assign(:challenges, page)
    |> assign(:pagination, pagination)
    |> assign(:base_url, Routes.api_challenge_url(conn, :index))
    |> render("index.json")
  end

  # TODO: Find better way to handle non valid IDs
  def show(conn, %{"id" => id}) do
    with {id, _} <- Integer.parse(id),
         {:ok, challenge} <- Challenges.get(id),
         true <- Challenges.is_public?(challenge) do
      conn
      |> assign(:challenge, challenge)
      |> put_status(:ok)
      |> render("show.json")
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> put_view(ErrorView)
        |> render("not_found.json")
    end
  end

  def preview(conn, %{"uuid" => uuid}) do
    with {:ok, uuid} <- Ecto.UUID.cast(uuid),
         {:ok, challenge} <- Challenges.get_by_uuid(uuid) do
      conn
      |> assign(:challenge, challenge)
      |> put_status(:ok)
      |> render("show.json")
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> put_view(ErrorView)
        |> render("not_found.json")
    end
  end
end
