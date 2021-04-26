defmodule Web.Api.PhaseWinnerController do
  use Web, :controller

  alias Web.ErrorView

  alias ChallengeGov.PhaseWinners

  def upload_overview_image(conn, %{"id" => id, "overview_image" => overview_image}) do
    {:ok, phase_winner} = PhaseWinners.get(id)

    case PhaseWinners.upload_overview_image(phase_winner, overview_image) do
      {:ok, overview_image_path} ->
        conn
        |> put_status(:created)
        |> assign(:overview_image_path, overview_image_path)
        |> render("upload_overview_image.json")

      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> put_status(:unprocessable_entity)
        |> put_view(ErrorView)
        |> render("errors.json")
    end
  end
end
