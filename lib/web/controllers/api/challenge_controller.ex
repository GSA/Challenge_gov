defmodule Web.Api.ChallengeController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias Web.Api.ErrorView

  plug Web.Plugs.FetchPage when action in [:index]

  def index(conn, %{"archived" => "true"} = params) do
    filter = Map.get(params, "filter", %{})
    
    # Extract the filter values from the query parameters
    primaryAgency = Map.get(filter, "primaryAgency", "")
    dateAdded = Map.get(filter, "dateAdded", "")
    lastDay = Map.get(filter, "lastDay", "")
    primaryChallengeType = Map.get(filter, "primaryChallengeType", "")
    keyword = Map.get(filter, "keyword", "")
    
    challenges = Challenges.all_archived(filter: filter)
    
    conn
    |> assign(:challenges, challenges)
    |> assign(:base_url, Routes.api_challenge_url(conn, :index, archived: true))
    |> render("index.json")
  end

  # def index(conn, _params) do
  #   challenges = Challenges.all_public()
  #   # IO.inspect(challenges, label: "Challenges")
  #   IO.puts("Debugging: Challenges fetched successfully")
  #   conn
  #   |> assign(:challenges, challenges)
  #   |> assign(:base_url, Routes.api_challenge_url(conn, :index))
  #   |> render("index.json")
  # end

  def index(conn, params) do
    filter = Map.get(params, "filter", %{})

    # Extract the filter values from the query parameters
    primaryAgency = Map.get(filter, "primaryAgency", "")
    dateAdded = Map.get(filter, "dateAdded", "")
    lastDay = Map.get(filter, "lastDay", "")
    primaryChallengeType = Map.get(filter, "primaryChallengeType", "")
    keyword = Map.get(filter, "keyword", "")

    challenges =
      if Map.keys(filter) == [] do
        Challenges.all_public()
      else
        Challenges.filter_archived(primaryAgency, dateAdded, lastDay, primaryChallengeType, keyword)
      end

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
