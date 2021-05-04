defmodule Web.Api.WinnerController do
  use Web, :controller

  alias Web.ErrorView

  alias ChallengeGov.PhaseWinners
  alias ChallengeGov.Winners

  plug Web.Plugs.FetchChallenge, id_param: "phase_winner_id"
  plug Web.Plugs.AuthorizeChallenge

  def upload_image(conn, %{"id" => id, "image" => image}) do
    {:ok, phase_winner} = PhaseWinners.get(id)

    case Winners.upload_image(phase_winner, image) do
      {:ok, image_path} ->
        conn
        |> put_status(:created)
        |> assign(:image_path, image_path)
        |> render("upload_image.json")

      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> put_status(:unprocessable_entity)
        |> put_view(ErrorView)
        |> render("errors.json")
    end
  end
end
