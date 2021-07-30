defmodule Web.Api.WinnerController do
  use Web, :controller

  alias Web.ErrorView

  alias ChallengeGov.PhaseWinners
  alias ChallengeGov.Winners

  plug Web.Plugs.FetchChallenge, [id_param: "phase_winner_id"] when action in [:upload_image]
  plug Web.Plugs.AuthorizeChallenge when action in [:upload_image]

  def upload_image(conn, %{"id" => id, "image" => image}) do
    {:ok, phase_winner} = PhaseWinners.get(id)

    case Winners.upload_image(phase_winner, image) do
      {:ok, winner} ->
        conn
        |> put_status(:created)
        |> assign(:key, winner.image_key)
        |> assign(:extension, winner.image_extension)
        |> render("upload_image.json")

      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> put_status(:unprocessable_entity)
        |> put_view(ErrorView)
        |> render("errors.json")
    end
  end

  def phase_winners(conn, %{"phase_id" => phase_id}) do
    case PhaseWinners.get_by_phase_id(phase_id) do
      {:ok, phase_winner} ->
        conn
        |> assign(:phase_title, phase_winner.phase.title)
        |> assign(:winner, phase_winner)
        |> put_status(:ok)
        |> render("phase_winner.json")

      {:error, :no_phase_winner} ->
        conn
        |> put_status(:ok)
        |> render("phase_winner.json")
    end
  end
end
