defmodule Web.Api.ChallengeController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias Web.Api.ErrorView

  plug Web.Plugs.FetchPage when action in [:index]

  def index(conn, params = %{"archived" => "true"}) do
    filter = Map.get(params, "filter", %{})

    challenges = Challenges.all_archived(filter: filter)

    conn
    |> assign(:challenges, challenges)
    |> assign(:base_url, Routes.api_challenge_url(conn, :index, archived: true))
    |> render("index.json")
  end

  # def index(conn, _params) do
  #   challenges = Challenges.all_public()

  #   json_challenges = for challenge <- challenges do
  #     %{
  #       id: challenge.id,
  #       status: challenge.status,
  #       sub_status: challenge.sub_status,
  #       end_date: challenge.end_date,
  #       inserted_at: challenge.inserted_at,
  #       primary_type: challenge.primary_type
  #     }
  #   end

  #   conn
  #   |> assign(:challenges, json_challenges)
  #   |> assign(:base_url, Routes.api_challenge_url(conn, :index))
  #   |> render("index.json")
  # end

  def index(conn, _params) do
    challenges = Challenges.all_public()

    conn
    |> assign(:challenges, challenges)
    |> assign(:base_url, Routes.api_challenge_url(conn, :index))
    |> render("index.json")
  end

  def show(conn, %{"id" => id}) do
    with {:ok, challenge} <- Challenges.get(id),
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
